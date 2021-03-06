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
    return self[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    self[key] = obj;
}

@end
