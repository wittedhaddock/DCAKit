//
//  NSError+LessTerrible.m
//  Adrenaline
//
//  Created by Drew Crawford on 1/9/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//
#define ISO_TIMEZONE_UTC_FORMAT @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT @"%+02d%02d"

#import "NSError+LessTerrible.h"
#import <UIKit/UIKit.h>

static NSString *exceptionalAPIKey;
static NSMutableDictionary *environment;

@implementation NSError (LessSuck)
- (NSString *)lessTerribleFailureReason {
    if ([self domain]==NSURLErrorDomain && [self code]==NSURLErrorUserCancelledAuthentication) {
        return @"User unauthorized.";
    }
    return [self localizedDescription];
}

- (NSString*) lessTerribleRecoverySuggestion {
    if ([self domain]==NSURLErrorDomain && [self code]==NSURLErrorUserCancelledAuthentication) {
        return @"Check your login credentials and try again.";
    }
    return [self localizedRecoverySuggestion];
}

-(void) present {
    [self log];
    NSString *title = [NSString stringWithFormat:@"%@ code %ld",self.domain,(long)self.code];
    NSString *message = [NSString stringWithFormat:@"%@\n%@",self.lessTerribleFailureReason,self.lessTerribleRecoverySuggestion];
    
    UIAlertView *uav = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [uav show];
    });
    
}

#pragma mark - Exceptional


-(NSString *) strFromISO8601:(NSDate *) date {
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        NSAssert([timeZone secondsFromGMT] < INT_MAX, @"Overflow condition.");
        int offset = (int) [timeZone secondsFromGMT];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyyMMdd'T'HH:mm:ss"];
        offset /= 60; //bring down to minutes
        if (offset == 0)
            [strFormat appendString:ISO_TIMEZONE_UTC_FORMAT];
        else
            [strFormat appendFormat:ISO_TIMEZONE_OFFSET_FORMAT, offset / 60, offset % 60];
        
        [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601 setDateFormat:strFormat];
    }
    return[sISO8601 stringFromDate:date];
}

+(void) setExceptionalAPIKey:(NSString*) exceptionalKey {
    exceptionalAPIKey = exceptionalKey;
    environment = [[NSMutableDictionary alloc] init];
}

-(NSMutableDictionary*) environment {
    return environment;
}

//http://docs.exceptional.io/api/publish/
-(void) log {
    if (!exceptionalAPIKey) {
        NSLog(@"Cannot log an error because no exceptional API key is set.  Consider creating one.");
        return;
    }
    NSDictionary *appDict = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *client = @{@"name":appDict[@"CFBundleName"],@"version":appDict[@"CFBundleVersion"],@"build":appDict[@"CFBundleShortVersionString"],@"deviceName":UIDevice.currentDevice.name,@"OSVersion":UIDevice.currentDevice.systemVersion,@"model":UIDevice.currentDevice.model,@"orientation":@(UIDevice.currentDevice.orientation),@"userInfo":[self.userInfo description]};
    for (id key in client.allKeys) {
        environment[[NSString stringWithFormat:@"__client_%@",key]]=client[key];
    }
    
    
    
    NSDictionary *dict = @{@"exception":@{@"backtrace" : [NSThread callStackSymbols],@"exception_class":self.domain,@"message":self.lessTerribleFailureReason,@"occurred_at":[self strFromISO8601:[NSDate date]]},@"application_environment":@{@"application_root_directory":@"Steve Jobs says no",@"env":environment}};
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.exceptional.io/api/errors?api_key=%@&protocol_version=6",exceptionalAPIKey]]];
    NSAssert([NSJSONSerialization isValidJSONObject:dict], @"Not a valid json object?");
    
    NSError *jsonErr = nil;
    NSData *errData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonErr];
    [request setHTTPBody:errData];
    [request setHTTPMethod:@"POST"];
    NSURLResponse *response = nil;
    NSError *err = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    
}
@end