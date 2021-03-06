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
+(ABAddressBookRef) newAddressBookWithError:(NSError* __autoreleasing*) error {
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
            if (error) {
                *error = (__bridge NSError*) innerError;
            }
        }
        else {
            if (error) {
                *error = [NSError errorWithDomain:kDCAAddressBookSerializerErrorDomain code:DCAABAddressBookSerializerNoPermission userInfo:nil];
            }
        }
        return NULL;
        
    }
    return addressBook;
}
+ (BOOL)serializeWithFileName:(NSString *)filePath error:(NSError *__autoreleasing *)error {

    ABAddressBookRef addressBook = [self newAddressBookWithError:error];
    
    NSArray *allPeople = (__bridge_transfer  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSData *vCardData = (__bridge_transfer NSData*) ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)(allPeople));
    BOOL ok = [vCardData writeToFile:filePath options:0 error:error];
    CFRelease(addressBook);
    return ok;
}
+(BOOL) deserializeWithFileName:(NSString*) filePath  deleteFirst:(BOOL) deleteFirst error:(NSError *__autoreleasing *) error {
    ABAddressBookRef addressBook = [self newAddressBookWithError:error];
    if (deleteFirst) {
        NSArray *allPeople = (__bridge_transfer  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id person in allPeople) {
            CFErrorRef innerError;
            if (!ABAddressBookRemoveRecord(addressBook, (__bridge ABRecordRef)(person), &innerError)) {
                CFRelease(addressBook);
                return NO;
            }
        }
    }
    CFErrorRef saveError;
    if (!ABAddressBookSave(addressBook, &saveError)) {
        if (error) {
            CFRelease(addressBook);
            *error = (__bridge NSError*) saveError;
            return NO;

        }
    }

    NSData *vCardData = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    if (!vCardData) {
        CFRelease(addressBook);
        return NO;
    }
    CFDataRef vCardDataRef = (__bridge CFDataRef)(vCardData);


    CFArrayRef people = ABPersonCreatePeopleInSourceWithVCardRepresentation(addressBook, vCardDataRef);
    CFRelease(addressBook);
    CFRelease(people);
    return YES;
}
@end
