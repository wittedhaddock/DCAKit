//
//  NSRegularExpression+helpers.h
//  DCA-libs
//
//  Created by Bion Oren on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRegularExpression (helpers)
+(NSRegularExpression*) regularExpressionWithSafePattern:(NSString*)pattern;
+(NSRegularExpression*) regularExpressionWithSafePattern:(NSString*)pattern options:(NSRegularExpressionOptions)flags;

+(NSRange) rangeOfExpression:(NSString*) regEx inHaystack:(NSString*) haystack;
+(BOOL) forceMatchExpression:(NSString*) regEx matchWith:(NSString*) haystack;

-(NSArray*) split:(NSString*)subject;

- (void)enumerateMatchesToArrayInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(NSArray* matches, NSMatchingFlags flags, BOOL *stop))bloc;
- (NSArray *)matchesToArrayInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
@end
