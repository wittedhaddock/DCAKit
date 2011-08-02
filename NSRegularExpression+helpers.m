//
//  NSRegularExpression+helpers.m
//  DCA-libs
//
//  Created by Bion Oren on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSRegularExpression+helpers.h"

#define REGEX_OPTIONS NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators

@implementation NSRegularExpression (helpers)

#pragma mark Constructors
+(NSRegularExpression*) regularExpressionWithSafePattern:(NSString*)pattern
{
    return [NSRegularExpression regularExpressionWithSafePattern:pattern options:REGEX_OPTIONS];
}

+(NSRegularExpression*) regularExpressionWithSafePattern:(NSString*)pattern options:(NSRegularExpressionOptions)flags
{
    NSError *error = nil;
    NSRegularExpression *ret = [NSRegularExpression regularExpressionWithPattern:pattern options:flags error:&error];
    if(error)
    {
        NSLog(@"Failed to compile pattern %@ with error %@", pattern, error);
        assert(NO);
        return nil;
    }
    return ret;
}

#pragma mark forceMatch
+(NSRange) rangeOfExpression:(NSString*) regEx inHaystack:(NSString*) haystack
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithSafePattern:regEx];
    NSRange r = [regex rangeOfFirstMatchInString:haystack options:0 range:NSMakeRange(0, haystack.length)];
    return r;
}

+(BOOL) forceMatchExpression:(NSString*) regEx matchWith:(NSString*) haystack
{
    return [self rangeOfExpression:regEx inHaystack:haystack].location==0;
}

#pragma mark split
-(NSArray*) split:(NSString*)subject
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:1];
    __block NSUInteger start = 0;
    NSRange range = NSMakeRange(0, [subject length]);
    [self enumerateMatchesInString:subject options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSUInteger end = result.range.location;
        [ret addObject:[subject substringWithRange:NSMakeRange(start, end-start)]];
        start = end+result.range.length;
    }];
    NSUInteger end = subject.length;
    if(start != end)
    {
        [ret addObject:[subject substringWithRange:NSMakeRange(start, end-start)]];
    }
    
    return ret;
}

#pragma mark matching sanely
- (void)enumerateMatchesToArrayInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(NSArray* matches, NSMatchingFlags flags, BOOL *stop))bloc
{
    [self enumerateMatchesInString:string options:options range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableArray *ret = [NSMutableArray arrayWithCapacity:result.numberOfRanges];
        for(int i = 0; i < result.numberOfRanges; i++)
        {
            [ret addObject:[string substringWithRange:[result rangeAtIndex:i]]];
        }
        bloc(ret, flags, stop);
    }];
}

- (NSArray *)matchesToArrayInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:1];
    [self enumerateMatchesToArrayInString:string options:options range:range usingBlock:^(NSArray *matches, NSMatchingFlags flags, BOOL *stop) {
        [ret addObject:matches];
    }];
    return ret;
}

@end
