//
//  ABAddressBookSerializer.m
//  DCAKit
//
//  Created by Drew Crawford on 12/2/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "DCAAddressbookSerializer.h"
#import <AddressBook/AddressBook.h>

@implementation DCAAddressbookSerializer
+(ABAddressBookRef) createAddressBookWithError:(NSError* __autoreleasing*) error {
    CFErrorRef innerError = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &innerError);
    __block BOOL accessGranted = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        NSLog(@"Point 3");
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
        NSLog(@"Granted: %d",accessGranted);
    });
    NSLog(@"Point 5");
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (!addressBook) {
        if (innerError) {
            *error = (__bridge NSError*) innerError;
        }
        else {
            *error = [NSError errorWithDomain:kDCAAddressBookSerializerErrorDomain code:DCAABAddressBookSerializerNoPermission userInfo:nil];
        }
        return NO;
        
    }
    return addressBook;
}
+ (BOOL)serializeWithFileName:(NSString *)filePath error:(NSError *__autoreleasing *)error {

    ABAddressBookRef addressBook = [self createAddressBookWithError:error];
    
    NSArray *allPeople = (__bridge_transfer  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSData *vCardData = (__bridge_transfer NSData*) ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)(allPeople));
    BOOL ok = [vCardData writeToFile:filePath options:0 error:error];
    CFRelease(addressBook);
    return ok;
}
+(BOOL) deserializeWithFileName:(NSString*) filePath  deleteFirst:(BOOL) deleteFirst error:(NSError *__autoreleasing *) error {
    ABAddressBookRef addressBook = [self createAddressBookWithError:error];
    if (deleteFirst) {
        NSArray *allPeople = (__bridge_transfer  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id person in allPeople) {
            CFErrorRef innerError;
            if (!ABAddressBookRemoveRecord(addressBook, (__bridge ABRecordRef)(person), &innerError)) {
                return NO;
            }
        }
    }
    CFErrorRef saveError;
    if (!ABAddressBookSave(addressBook, &saveError)) {
        *error = (__bridge NSError*) saveError;
        return NO;
    }

    NSData *vCardData = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    if (!vCardData) {
        return NO;
    }
    CFDataRef vCardDataRef = (__bridge CFDataRef)(vCardData);


    ABPersonCreatePeopleInSourceWithVCardRepresentation(addressBook, vCardDataRef);
    
    CFRelease(addressBook);
    return YES;
}
@end
