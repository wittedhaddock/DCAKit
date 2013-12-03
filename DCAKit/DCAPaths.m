//
//  DCAPaths.m
//  DCAKit
//
//  Created by Drew Crawford on 12/3/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "DCAPaths.h"

@implementation DCAPaths
+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
@end
