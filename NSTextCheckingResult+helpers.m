//
//  NSTextCheckingResult+helpers.m
//  DCA-libs
//
//  Created by Bion Oren on 8/9/11.
//  Copyright 2011 DrewCrawfordApps. All rights reserved.
//

#import "NSTextCheckingResult+helpers.h"

@implementation NSTextCheckingResult (helpers)
-(NSArray*)matchesForString:(NSString*)string
{
    NSMutableArray *ret = [[[NSMutableArray alloc] initWithCapacity:[self numberOfRanges]] autorelease];
    for(NSUInteger i = 0; i < [self numberOfRanges]; i++)
    {
        [ret addObject:[string substringWithRange:[self rangeAtIndex:i]]];
    }
    return ret;
}
@end
