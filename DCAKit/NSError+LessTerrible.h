//
//  NSError+LessTerrible.h
//  Adrenaline
//
//  Created by Drew Crawford on 1/9/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (LessSuck)
/**Less terrible errors */
-(NSString*) lessTerribleFailureReason;

/**Displays the error and logs it to the backing store if necessary*/
-(void) present;

/**Indicates that errors with this domain and code should not be logged or displayed.*/
-(void) whitelist;

+(void) setExceptionalAPIKey:(NSString*) exceptionalKey;
@end