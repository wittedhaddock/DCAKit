//
//  DCASimpleKeychain.m
//  DCAKit
//
//  Created by Drew Crawford on 1/23/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "DCASimpleKeychain.h"
#import <Security/Security.h>
@implementation DCASimpleKeychain
- (NSMutableDictionary *)searchDictionaryWithKey:(id)key {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)(kSecClassGenericPassword);
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id<NSCopying>)(kSecAttrService)] = @"DCASimpleKeychain";
    searchDictionary[(__bridge id)kSecAttrAccount] = key;
    searchDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    return searchDictionary;
}

+ (DCASimpleKeychain *)anyKeychain {
    return [[DCASimpleKeychain alloc] init];
}

- (id)objectForKeyedSubscript:(id)key {
    NSAssert([key isKindOfClass:[NSString class]], @"Must key on strings.");
    NSMutableDictionary *searchDictionary = [self searchDictionaryWithKey:key];
    
    CFDataRef data = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef*)&data);
    if (!data) return nil;
    return [[NSString alloc] initWithData:(__bridge NSData*) data encoding:NSUTF8StringEncoding];
}
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    NSAssert([(id) key isKindOfClass:[NSString class]], @"Must key on strings.");
    NSAssert([obj isKindOfClass:[NSString class]], @"Must store strings.");

    NSMutableDictionary *searchDictionary = [self searchDictionaryWithKey:key];
    
    if (self[key]) {
        //update case
        [searchDictionary removeObjectForKey:(__bridge id) kSecReturnData]; //these two keys cause
        [searchDictionary removeObjectForKey:(__bridge id) kSecMatchLimit]; //-50 OSError
        NSDictionary *updateData = @{(__bridge id)kSecValueData:[obj dataUsingEncoding:NSUTF8StringEncoding]};
        OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)(searchDictionary), (__bridge CFDictionaryRef)(updateData));
        if (result != errSecSuccess) {
            NSLog(@"Keychain error code %d",(int)result);
            abort();
        }
    }
    else {
        //add case
        NSDictionary *addData = @{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrService:@"DCASimpleKeychain",(__bridge id)kSecAttrAccount:key,(__bridge id)kSecValueData:[obj dataUsingEncoding:NSUTF8StringEncoding]};
        
        OSStatus result = SecItemAdd((__bridge CFDictionaryRef)(addData), NULL);
        if (result != errSecSuccess) {
            NSLog(@"Keychain error code %d",(int)result);
            abort();
        }
    }
    
    
    
}
@end
