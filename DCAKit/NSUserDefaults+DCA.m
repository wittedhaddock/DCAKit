//
//  NSUserDefaults+DCA.m
//  DCAKit
//
//  Created by Drew Crawford on 12/3/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "NSUserDefaults+DCA.h"

@implementation NSUserDefaults (DCA)
+ (void)actuallyResetStandardUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in defaults.dictionaryRepresentation.allKeys) {
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
    CFArrayCreate(NULL, NULL, 0, NULL);
    
}
@end
