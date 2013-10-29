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
#import "DCAPaperTrail.h"

static NSString *exceptionalAPIKey;
static NSMutableDictionary *environment;

/**Contains Domain_Code for all errors that we whitelist (ignore) */
static NSMutableSet *whitelistedErrors;

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

-(void) whitelist {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whitelistedErrors = [[NSMutableSet alloc] init];
    });
    @synchronized(whitelistedErrors) {
        [whitelistedErrors addObject:[NSString stringWithFormat:@"%@_%d",self.domain,self.code]];
    }
}

-(void) present {
    @synchronized(whitelistedErrors) {
        if ([whitelistedErrors containsObject:[NSString stringWithFormat:@"%@_%d",self.domain,self.code]]) {
            return;
        }
    }
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
}

-(void) log {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        environment = [[NSMutableDictionary alloc] init];
    });
    NSDictionary *appDict = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *client = @{@"name":appDict[@"CFBundleName"],@"version":appDict[@"CFBundleVersion"],@"build":appDict[@"CFBundleShortVersionString"],@"deviceName":UIDevice.currentDevice.name,@"OSVersion":UIDevice.currentDevice.systemVersion,@"model":UIDevice.currentDevice.model,@"orientation":@(UIDevice.currentDevice.orientation),@"userInfo":[self.userInfo description]};
    for (id key in client.allKeys) {
        environment[[NSString stringWithFormat:@"__client_%@",key]]=client[key];
    }
    
    NSDictionary *dict = @{@"exception":@{@"backtrace" : [NSThread callStackSymbols],@"exception_class":self.domain,@"message":self.lessTerribleFailureReason,@"occurred_at":[self strFromISO8601:[NSDate date]]},@"application_environment":@{@"application_root_directory":@"Steve Jobs says no",@"env":environment}};
    NSAssert([NSJSONSerialization isValidJSONObject:dict], @"Not a valid json object?");
    
    NSError *jsonErr = nil;
    NSData *errData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonErr];
    NSString *errString = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
    PTLog(@"%@",errString);
    PTLog(@"Set a breakpoint at -[NSError log] to debug.");
    
    
}
@end