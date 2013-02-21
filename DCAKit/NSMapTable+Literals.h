//
//  NSMapTable+Literals.h
//  DCAKit
//
//  Created by Drew Crawford on 2/21/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMapTable (Literals)
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id) key;
@end
