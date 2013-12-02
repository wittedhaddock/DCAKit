//
//  ABAddressBookSerializer.h
//  DCAKit
//
//  Created by Drew Crawford on 12/2/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h> //link address book framework if this file is imported

#define kDCAAddressBookSerializerErrorDomain @"ABAddressBookSerializerErrorDomain"
typedef NS_ENUM(NSInteger,DCAAddressBookSerializerErrorCode) {
    DCAABAddressBookSerializerNoPermission,
};

@interface DCAAddressbookSerializer : NSObject

/** Serializes the address book to the file
 @param filePath path to store address book
 @param error out error
 @return YES on success, NO on failure */
+(BOOL) serializeWithFileName:(NSString*) filePath error:(NSError*__autoreleasing*) error;

/** Deserializes the address book from the file
 @param filePath path to read address book data
 @param deleteFirst the local address book should be deleted before import
 @param error out error
 
 @warning if deleteFirst==YES, this is a VERY DESTRUCTIVE OPERATION
 @return YES on success, NO on failure */
+(BOOL) deserializeWithFileName:(NSString*) filePath  deleteFirst:(BOOL) deleteFirst error:(NSError *__autoreleasing *) error;

@end
