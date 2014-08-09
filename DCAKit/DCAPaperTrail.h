//
//  DCAPaperTrail.h
//  DCAKit
//
//  Created by Drew Crawford on 10/1/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DCAPaperTrail : NSObject

+(void) configureWithHostname:(NSString*) hostname port:(int) port;
+(void) logFormat:(NSString*) format, ... NS_FORMAT_FUNCTION(1,2);
+(void) logNoArgs:(NSString*) stringToLog;
void PTLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
+(NSString*) incidentID;
@end
