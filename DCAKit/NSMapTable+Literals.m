//
//  NSMapTable+Literals.m
//  DCAKit
//
//  Created by Drew Crawford on 2/21/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "NSMapTable+Literals.h"

@implementation NSMapTable (Literals)
- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    return [self setObject:obj forKey:key];
}

@end
