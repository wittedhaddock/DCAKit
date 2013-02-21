//
//  DCASimpleKeychain.h
//  DCAKit
//
//  Created by Drew Crawford on 1/23/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

/**Keychains suck: a manifesto.
 
 One of the important rules in security is that the defaults should be right.  A secure component is one that you drop in, configure nothing, and everything works.  Nothing to remember, zero room for error.  Keychain is not that component.
 
 Keychain's long list of configuration options include, but are not limited to: access groups, a query language, a bunch of stuff from OSX that doesn't even work on iOS, a whopping 41 different attribute keys (including such shining stars as an attribute that indicates that the password should be stored, but never used for any purpose, e.g. write-only memory), five different storage classes that differ from each other very little, 31 different protocols (some of which are undocumented Apple protocols, included for no particular reasons), customizing the security policy of keys, **including disabling security altogether** (which is all kinds of stupid), and who knows what else is in here really.
 
 Instead of that, just do this:
 
 simpleKeychain[@"password"] = @"p4ssw0rd";
 
 @warning The keychain is one of the few places that data survives reset simulator or deleting the app.  Make sure you test all your codepaths.
 
 */
@interface DCASimpleKeychain : NSObject

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

+(DCASimpleKeychain*) anyKeychain;


@end
