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
+(void) log:(NSString*) format, ... NS_FORMAT_FUNCTION(1,2);
void PTLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
+(NSString*) incidentID;
@end
