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
-(void) present;

//any keys you set in here will get reported with errors...
@property (readonly) NSMutableDictionary *environment;

+(void) setExceptionalAPIKey:(NSString*) exceptionalKey;
@end