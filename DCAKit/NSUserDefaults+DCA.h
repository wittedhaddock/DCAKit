//
//  NSUserDefaults+DCA.h
//  DCAKit
//
//  Created by Drew Crawford on 12/3/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DCA)
/** +[NSUserDefaults resetStandardUserDefaults doesn't do what you think. */
+(void) actuallyResetStandardUserDefaults;
@end
