//
//  AppEngineDelegate.h
//  briefcasewars
//
//  Created by Bion Oren on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kRETRY,
    kFAIL
} recovery_method;

typedef enum {
    kPLIST,
    kJSON
} response_type;

@interface HTTPRequest : NSObject {
    recovery_method recoveryMethod;
    response_type responseType;
    NSString *baseURL;
}

@property (nonatomic, assign) recovery_method recoveryMethod;
@property (nonatomic, assign) response_type responseType;
@property (nonatomic, retain) NSString *baseURL;

-(id)initWithBlock:(void (^)(NSObject*))newBlock;
+ (NSString*) fixTheString:(NSString*) fixMe;
+(bool) testConnection;
-(void) setParameter:(NSObject*)value forKey:(NSString*)key;
-(void) requestWithPrefix:(NSString*)prefix;
-(void) requestWithPrefix:(NSString*)prefix params:(NSDictionary*)parameters;
-(void) requestWithPrefix:(NSString*)prefix post:(BOOL)post;
-(void) requestWithPrefix:(NSString*)prefix params:(NSDictionary*)parameters post:(BOOL)post;

@end
