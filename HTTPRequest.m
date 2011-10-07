//
//  AppEngineDelegate.m
//  briefcasewars
//
//  Created by Bion Oren on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPRequest.h"
#import "LogBuddy.h"
#import "SBJson.h"

#define GET_STR_BYTES(DATA) [[NSString alloc] initWithBytes:[DATA bytes] length:[DATA length] encoding:NSUTF8StringEncoding]

@interface HTTPRequest ()
{
    int retainCount;
    BOOL connectionInProgress;
    HTTPRequest __strong *internalReference;
}

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;
//state variables to retry requests
@property (nonatomic, strong) NSMutableDictionary *getParams;
@property (nonatomic, strong) NSMutableDictionary *postParams;
@property (nonatomic, strong) NSString* prefix;
@property (nonatomic, copy) void (^block)(NSObject*);

-(void) internalRetain;
-(void) internalRelease;

@end

@implementation HTTPRequest
@synthesize receivedData;
@synthesize connection;
@synthesize getParams;
@synthesize postParams;
@synthesize recoveryMethod;
@synthesize responseType;
@synthesize prefix;
@synthesize baseURL;
@synthesize requestMethod;
@synthesize block;

- (id)initWithBlock:(void (^)(NSObject*))newBlock
{
    if((self = [super init]))
    {
        self.block = newBlock;
        self.getParams = [[NSMutableDictionary alloc] init];
        self.postParams = [[NSMutableDictionary alloc] init];
        self.recoveryMethod = kFAIL;
        self.responseType = kPLIST;
        self.requestMethod = @"GET";
        retainCount = 0;
    }
    return self;
}

-(void) internalRetain
{
    internalReference = self;
    retainCount++;
    assert(retainCount <= 1 || (retainCount <= 2 && self.recoveryMethod == kRETRY));
}

-(void) internalRelease
{
    retainCount--;
    if (retainCount==0) internalReference = nil;
    assert(retainCount >= 0);
}

+(NSString*) fixTheString:(NSString*)fixMe
{
    NSString *ret = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[fixMe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    //No periods. You can't escape them, because everyone not FF ignores your escaping and says, "Oh, I bet you actually wanted a period. I'll fix that for you!", leaving you to sit and cry, "NO! I escaped it for a reason dang it!!!". And then you get logbuddy tracebacks and your life generally sucks. So no periods.
    return ret;
}

+(NSString*)paramStringFromParams:(NSDictionary*)params
{
    NSMutableString *ret = [[NSMutableString alloc] initWithString:@"php=future"];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(obj) //ignore null entries
        {
            [ret appendString:[NSString stringWithFormat:@"&%@=%@", [[self class] fixTheString: key], [[self class] fixTheString: [NSString stringWithFormat:@"%@",obj]]]];
        }
    }];
    return ret;
}

-(void) setURLParameter:(NSObject*)value forKey:(NSString*)key
{
    [self.getParams setValue:value forKey:key];
}

-(void) setBodyParameter:(NSObject*)value forKey:(NSString*)key
{
    [self.postParams setValue:value forKey:key];
}

-(void) clearURLParameters
{
    [getParams removeAllObjects];
}

-(void) clearBodyParameters
{
    [postParams removeAllObjects];
}
-(void) beginSynchronousRequestWithPrefix:(NSString*) uprefix
{
    void (^myBlock)(NSObject*)  = self.block;
    dispatch_semaphore_t holdOn = dispatch_semaphore_create(0);
    self.block = ^(NSObject * obj) {
        myBlock(obj);
        dispatch_semaphore_signal(holdOn);
    };
    [self beginRequestWithPrefix:uprefix];
    dispatch_semaphore_wait(holdOn, DISPATCH_TIME_FOREVER);
    
}
-(void) beginRequestWithPrefix:(NSString*)uprefix
{
    [self beginRequestWithPrefix:uprefix method:requestMethod];
}

-(void) beginRequestWithPrefix:(NSString*)uprefix method:(NSString*)method
{
    [self beginRequestWithPrefix:uprefix method:method URLParams:nil bodyParams:nil];
}

-(void) beginRequestWithPrefix:(NSString*)uprefix URLParams:(NSDictionary*)uURLParams bodyParams:(NSDictionary*)uBodyParams;
{
    [self beginRequestWithPrefix:uprefix method:requestMethod URLParams:uURLParams bodyParams:uBodyParams];
}

-(void) beginRequestWithPrefix:(NSString*)uprefix method:(NSString*)method URLParams:(NSDictionary*)ugetParams bodyParams:(NSDictionary*)uBodyParams;
{
    assert(self.baseURL);
    assert([self.baseURL hasSuffix:@"/"] ^ [uprefix hasPrefix:@"/"]);
    assert(self.requestMethod || method);
    if (connectionInProgress)
    {
        NSLog(@"Ignoring this request because a connection is already in progress.");
        return;
    }
    [self internalRetain];
    connectionInProgress = YES;
    self.prefix = uprefix;
    if(method)
    {
        self.requestMethod = method;
    }
    [getParams addEntriesFromDictionary:getParams];
    [postParams addEntriesFromDictionary:postParams];
    
    NSString *urlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.baseURL, prefix]];
    if(getParams.count > 0)
    {
        urlString = [NSString stringWithFormat:@"%@?%@", urlString, [HTTPRequest paramStringFromParams:getParams]];
    }
    
    NSLog(@"URL = %@", urlString);
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [theRequest setHTTPMethod:self.requestMethod];
    if(postParams.count > 0)
    {
        [theRequest setHTTPBody:[[HTTPRequest paramStringFromParams:postParams] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.connection cancel];
        self.connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (connection)
        {
            // Create the NSMutableData to hold the received data.        
            // receivedData is an instance variable declared elsewhere.
            self.receivedData = [[NSMutableData alloc] init];
            NSLog(@"Plist request sent");
        }
        else
        {
            [LogBuddy reportErrorString: @"Unable to connect to appengine :("];
            [self internalRelease];
        }
        //wait for a response
        CFRunLoopRun();
    });
}

+(bool) testConnection
{
    NSURL* url = [[NSURL alloc] initWithString:@"http://www.google.com/"];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    if(![NSURLConnection canHandleRequest:request])
    {
        return false;
    }
    return true;
}

#pragma Connection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.receivedData = nil;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.connection = nil;
    connectionInProgress = NO;
    if(self.recoveryMethod == kFAIL)
    {
        NSLog(@"ERROR: %@", error);
    }
    else
    {
        NSLog(@"%@",error);
        sleep(2);
        [self beginRequestWithPrefix:self.prefix];
        NSLog(@"retrying %@...", self.prefix);
    }
    [self internalRelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    connectionInProgress = NO;
    if(receivedData && [receivedData length] > 0)
    {
        NSError *serror = nil;
        NSObject *arg;
        switch (responseType) {
            case kPLIST:
                {
                    NSString *result = GET_STR_BYTES(self.receivedData);
                    arg = [NSPropertyListSerialization propertyListWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListImmutable format:NULL error:&serror];
                    if(serror)
                    {
                        [LogBuddy reportNSError:serror];
                    }
                }
                break;
            case kJSON:
                {
                    DCASBJsonParser *parser = [[DCASBJsonParser alloc] init];
                    arg = [parser objectWithData:self.receivedData];
                    if(!arg)
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:parser.error forKey:NSLocalizedDescriptionKey];
                        serror = [[NSError alloc] initWithDomain:@"HTTPRequest" code:41 userInfo:userInfo];
                        [LogBuddy reportNSError:serror];
                    }
                }
                break;
            default:
                break;
        }
        if(!serror)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                block(arg);
            });
        }
        self.receivedData = nil;
		CFRunLoopStop(CFRunLoopGetCurrent());
    }
    self.connection = nil;
    [self internalRelease];
}


@end
