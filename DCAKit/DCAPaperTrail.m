//
//  DCAPaperTrail.m
//  DCAKit
//
//  Created by Drew Crawford on 10/1/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//




#import "DCAPaperTrail.h"

@import UIKit;
@import SystemConfiguration;
#include <sys/types.h>
#include <sys/sysctl.h>
#include <pthread.h>


static DCAPaperTrail *singleton;
NSString *hardwareString(void);
NSString *hardwareString () {
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = @(hw_machine);
    free(hw_machine);
    return hardware;
}

/* Threading guide.
 
 Logs come in and are dispatched onto the loggingQueue.  This is so we can return immediately.
 They are processed and formatted
 Then synchronously they are processed onto the internalThread for network dispatch.*/
@interface DCAPaperTrail()<NSStreamDelegate> {
    NSString *_hostname;
    int _port;
    NSInputStream *_readStream;
    NSOutputStream *_writeStream;
    NSThread *_internalThread;
    NSRunLoop *_internalRunLoop;
    dispatch_semaphore_t doneSettingUpSemaphore;
    
    dispatch_queue_t loggingQueue;
}
@end
@implementation DCAPaperTrail

-(void) startInternal {
    pthread_setname_np("DCAPaperTrailThread");
    _internalRunLoop = [NSRunLoop currentRunLoop];
    [self reconnect];
    dispatch_semaphore_signal(doneSettingUpSemaphore);
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

-(void) reconnect {
    NSLog(@"Reconnecting...");
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) _hostname, _port, &readStream, &writeStream);
    _readStream = (__bridge_transfer NSInputStream*)readStream;
    _writeStream = (__bridge_transfer NSOutputStream*) writeStream;
    _writeStream.delegate = self;
    NSAssert([NSRunLoop currentRunLoop]==_internalRunLoop, @"Unexpectedly not the internal runloop??");
    
    //Papertrail accepts messages over TCP with TLS. Unencrypted TCP is not generally supported
    [_writeStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    [_writeStream scheduleInRunLoop:_internalRunLoop forMode:(NSString*)kCFRunLoopDefaultMode];
    [_writeStream open];
}
-(id) initWithHostname:(NSString*) hostname port:(int) port {
    if (self = [super init]) {
        loggingQueue = dispatch_queue_create("DCAPaperTrailQueue", DISPATCH_QUEUE_SERIAL);
        _hostname = hostname;
        _port = port;
        doneSettingUpSemaphore = dispatch_semaphore_create(0);
        _internalThread = [[NSThread alloc] initWithTarget:self selector:@selector(startInternal) object:nil];
        [_internalThread start];
        dispatch_semaphore_wait(doneSettingUpSemaphore, DISPATCH_TIME_FOREVER);
    }
    return self;
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    if (streamEvent==NSStreamEventHasSpaceAvailable) return;
    NSLog(@"DCAPaperTrail handleEvent %lu",(unsigned long) streamEvent);
}

- (void)dealloc {
    [_writeStream removeFromRunLoop:_internalRunLoop forMode:(NSString*)kCFRunLoopDefaultMode];
    [_writeStream close];
}

static NSMutableString *incidentID;
+ (NSString *)incidentID {
    return incidentID;
}

+ (void)configureWithHostname:(NSString *)hostname port:(int)port {
    singleton = [[DCAPaperTrail alloc] initWithHostname:hostname port:port];
    PTLog(@"model %@",hardwareString());
    PTLog(@"OS version %@",[UIDevice currentDevice].systemVersion);
    PTLog(@"app version %@",[[NSBundle mainBundle]  objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]);
    //compute incident ID
    incidentID = [[NSMutableString alloc] init];
    [incidentID appendString:[[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:5]];
    NSUUID *incident = [[NSUUID alloc] init];
    [incidentID appendString:@"-"];
    [incidentID appendString:[incident.UUIDString substringToIndex:5]];
    [incidentID appendString:@"-"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    [incidentID appendString:[NSString stringWithFormat:@"%ld-%ld",(long)components.month,(long)components.day]];
    PTLog(@"Incident ID %@",incidentID);
    
    
}

-(void) innerLog:(NSString*) message {
    NSData *sysLogData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger bytes = [_writeStream write:[sysLogData bytes] maxLength:(int)sysLogData.length];
    if (bytes==-1) {
        NSLog(@"%@",_writeStream.streamError);
        //reconnect
        [self reconnect];
    }
}



-(void) log:(NSString *) format arguments:(va_list) args {
    NSString *replacedLog = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@",replacedLog);
    //the iOS simulator is pretty unreliable about identifierForVendor, so it's better not to log here I guess
#if TARGET_IPHONE_SIMULATOR
    return;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunreachable-code"
#endif
    dispatch_async(loggingQueue, ^{
        
        static dispatch_once_t onceToken;
        static NSDateFormatter *formatter;
        
        NSDate *date = [[NSDate alloc] init];
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            
            //https://tools.ietf.org/html/rfc5424#section-6.2.3
            //http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
            //1985-04-12T19:20:50.52-04:00
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSZZZZZ";
        });
        NSMutableString *sysLog = [[NSMutableString alloc] initWithString:@"<22>"];
        [sysLog appendString:[formatter stringFromDate:date]];
        [sysLog appendString:@" "];
        
        NSString *identifier =[[UIDevice currentDevice] identifierForVendor].UUIDString;
        [sysLog appendString:[identifier stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
        [sysLog appendString:@" "];
        
        [sysLog appendString:[[NSBundle mainBundle]  bundleIdentifier]];
        [sysLog appendString:@": "];
        
        [sysLog appendString:replacedLog];
        [sysLog appendString:@"\n"];
        
        [self performSelector:@selector(innerLog:) onThread:_internalThread withObject:sysLog waitUntilDone:YES];
    });
#if TARGET_IPHONE_SIMULATOR
#pragma clang diagnostic pop
#endif
}

+(void) logFormat:(NSString*) format arguments:(va_list) args {
    if (!singleton) {
        NSLogv(format, args);
        return;
    }
    [singleton log:format arguments:args];
}

+(void) logFormat:(NSString*) format, ... {
    va_list args;
    va_start(args, format);
    [self logFormat:format arguments:args];
    va_end(args);
}

+(void) logNoArgs:(NSString *)stringToLog {
    [self logFormat:stringToLog arguments:nil];
}

void PTLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [DCAPaperTrail logFormat:format arguments:args];
    va_end(args);
}





@end
