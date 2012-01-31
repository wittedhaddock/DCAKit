//
//  AppEngineDelegate.h
//  briefcasewars
//
//  Created by Bion Oren on 4/20/11.
//  Copyright 2011 DrewCrawfordApps LLC. All rights reserved.
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

/**Makes arbitrary HTTP requests using JSON or PLIST */
@interface HTTPRequest : NSObject

/**Whether or not the request should be retried. The default is kFAIL.*/
@property (nonatomic, assign) recovery_method recoveryMethod;

/*Whether we expect kPLIST or kJSON formats.  The default is PLIST. */
@property (nonatomic, assign) response_type responseType;

/**The base URL.  Either end this with / or the uprefix should begin with /.*/
@property (nonatomic, copy) NSString *baseURL;

/**The HTTP method.  The default is GET.*/
@property (nonatomic, copy) NSString *requestMethod;


-(id)initWithBlock:(void (^)(NSObject*))newBlock;

/**Makes a request to Google. */
+(bool) testConnection;
+(NSString*)fixTheString:(NSString*)fixMe;
+(NSString*)paramStringFromParams:(NSDictionary*)params;

-(void) setURLParameter:(NSObject*)value forKey:(NSString*)key;
-(void) setBodyParameter:(NSObject*)value forKey:(NSString*)key;
-(void) clearURLParameters;
-(void) clearBodyParameters;

-(void) beginSynchronousRequestWithPrefix:(NSString*) uprefix;
-(void) beginRequestWithPrefix:(NSString*)uprefix;
-(void) beginRequestWithPrefix:(NSString*)uprefix method:(NSString*)method;
-(void) beginRequestWithPrefix:(NSString*)uprefix URLParams:(NSDictionary*)uURLParams bodyParams:(NSDictionary*)uBodyParams;
-(void) beginRequestWithPrefix:(NSString*)uprefix method:(NSString*)method URLParams:(NSDictionary*)uURLParams bodyParams:(NSDictionary*)uPostParams;

@end
