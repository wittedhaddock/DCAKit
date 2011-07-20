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

#define GET_STR_BYTES(DATA) [[[NSString alloc] initWithBytes:[DATA bytes] length:[DATA length] encoding:NSUTF8StringEncoding] autorelease]

@interface HTTPRequest ()
{
    NSMutableData *receivedData;
    NSURLConnection *connection;
    void (^block)(NSObject*);
    NSMutableDictionary *params;
    
    //state variables to retry requests
    NSString *prefix;
    BOOL post;
}
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSString* prefix;
@property (nonatomic, assign) BOOL post;
@end

@implementation HTTPRequest
@synthesize receivedData;
@synthesize connection;
@synthesize params;
@synthesize recoveryMethod;
@synthesize responseType;
@synthesize prefix;
@synthesize post;
@synthesize baseURL;

- (id)initWithBlock:(void (^)(NSObject*))newBlock
{
    if((self = [super init]))
    {
        block = [newBlock copy];
        self.params = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
        self.recoveryMethod = kFAIL;
        self.responseType = kPLIST;
    }
    return self;
}

+ (NSString*) fixTheString:(NSString*) fixMe
{
    //No periods. You can't escape them, because everyone not FF ignores your escaping and says, "Oh, I bet you actually wanted a period. I'll fix that for you!", leaving you to sit and cry, "NO! I escaped it for a reason dang it!!!". And then you get logbuddy tracebacks and your life generally sucks. So no periods.
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)fixMe, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8) stringByReplacingOccurrencesOfString:@"." withString:@""];
}

-(void) setParameter:(NSObject*)value forKey:(NSString*)key
{
    [self.params setValue:value forKey:key];
}

-(void) requestWithPrefix:(NSString*)uprefix
{
    [self requestWithPrefix:uprefix params:nil];
}

-(void) requestWithPrefix:(NSString*)uprefix post:(BOOL)upost
{
    [self requestWithPrefix:uprefix params:nil post:upost];
}

-(void) requestWithPrefix:(NSString*)uprefix params:(NSDictionary*)parameters
{
    [self requestWithPrefix:uprefix params:parameters post:NO];
}

-(void) requestWithPrefix:(NSString*)uprefix params:(NSDictionary*)parameters post:(BOOL)upost
{
    assert([self.baseURL hasSuffix:@"/"]);
    self.prefix = uprefix;
    self.post = upost;
    [self.params setValuesForKeysWithDictionary:parameters];
    
    NSString *urlString = [[[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.baseURL, prefix]] autorelease];
    NSMutableString *paramString = [[[NSMutableString alloc] initWithString:@"php=future"] autorelease];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramString appendString:[NSString stringWithFormat:@"&%@=%@", [[self class] fixTheString: key], [[self class] fixTheString: [NSString stringWithFormat:@"%@",obj]]]];
    }];
    if(!post)
    {
        urlString = [NSString stringWithFormat:@"%@?%@", urlString, paramString];
    }
    
    NSLog(@"URL = %@", urlString);
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    if(post)
    {
        [theRequest setHTTPMethod:@"POST"];
        [theRequest setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.connection cancel];
        self.connection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
        
        if (connection)
        {
            // Create the NSMutableData to hold the received data.        
            // receivedData is an instance variable declared elsewhere.
            self.receivedData = [[[NSMutableData alloc] init] autorelease];
            NSLog(@"Plist request sent");
        }
        else
        {
            [LogBuddy reportErrorString: @"Unable to connect to appengine :("];
        }
        //wait for a response
        CFRunLoopRun();
    });
}

+(bool) testConnection
{
    NSURL* url = [[[NSURL alloc] initWithString:@"http://www.google.com/"] autorelease];
    NSURLRequest* request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
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
    if(self.recoveryMethod == kFAIL)
    {
        NSLog(@"ERROR: %@", error);
    }
    else
    {
        NSLog(@"%@",error);
        sleep(2);
        [self requestWithPrefix:self.prefix params:nil post:self.post];
        NSLog(@"retrying %@...", self.prefix);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
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
                    DCASBJsonParser *parser = [[[DCASBJsonParser alloc] init] autorelease];
                    arg = [parser objectWithData:self.receivedData];
                    if(!arg)
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:parser.error forKey:NSLocalizedDescriptionKey];
                        serror = [[[NSError alloc] initWithDomain:@"HTTPRequest" code:41 userInfo:userInfo] autorelease];
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
}

- (void)dealloc
{
    self.baseURL = nil;
    self.prefix = nil;
    self.params = nil;
    self.receivedData = nil;
    self.connection = nil;
    [super dealloc];
}

@end
