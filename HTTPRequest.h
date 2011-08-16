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

@interface HTTPRequest : NSObject

@property (nonatomic, assign) recovery_method recoveryMethod;
@property (nonatomic, assign) response_type responseType;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *requestMethod;

-(id)initWithBlock:(void (^)(NSObject*))newBlock;
+(bool) testConnection;
+(NSString*)fixTheString:(NSString*)fixMe;
+(NSString*)paramStringFromParams:(NSDictionary*)params;

-(void) setGetParameter:(NSObject*)value forKey:(NSString*)key;
-(void) setPostParameter:(NSObject*)value forKey:(NSString*)key;
-(void) clearGetParameters;
-(void) clearPostParameters;
-(void) requestWithPrefix:(NSString*)uprefix;
-(void) requestWithPrefix:(NSString*)uprefix method:(NSString*)method;
-(void) requestWithPrefix:(NSString*)uprefix getParams:(NSDictionary*)ugetParams postParams:(NSDictionary*)upostParams;
-(void) requestWithPrefix:(NSString*)uprefix method:(NSString*)method getParams:(NSDictionary*)ugetParams postParams:(NSDictionary*)upostParams;

@end
