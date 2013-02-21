//
//  NSTextCheckingResult+helpers.h
//  DCA-libs
//
//  Created by Bion Oren on 8/9/11.
//  Copyright 2011 DrewCrawfordApps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTextCheckingResult (helpers)
-(NSArray*)matchesForString:(NSString*)string;
@end
