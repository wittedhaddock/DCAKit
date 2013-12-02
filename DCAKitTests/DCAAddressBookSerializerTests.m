//
//  DCAAddressbookSerializerTests.m
//  DCAKit
//
//  Created by Drew Crawford on 12/2/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "DCAAddressbookSerializerTests.h"
#import "DCAAddressbookSerializer.h"

@implementation DCAAddressbookSerializerTests
-(void) testSerialize {
    NSError *err = nil;
    BOOL ok = [DCAAddressbookSerializer serializeWithFileName:@"/tmp/test.vcards" error:&err];
    XCTAssertNil(err, @"Error ocurred");
    XCTAssert(ok, @"Not ok when serializing");
}
-(void) testDeserialize {
    NSError *err = nil;

    [self testSerialize];
    BOOL ok = [DCAAddressbookSerializer deserializeWithFileName:@"/tmp/test.vcards" deleteFirst:YES error:&err];
    XCTAssertNil(err, @"Error ocurred");
    XCTAssertTrue(ok, @"Not ok when deserializing");
}
@end
