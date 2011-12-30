//
//  FormField.m
//  CarAccidentHelp
//
//  Created by Bion Oren on 12/21/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import "DCAUIControl.h"
#import "UIControl+CaptureUIControlEvents.h"

@interface DCAUIControl ()

@property (nonatomic, strong) NSMutableDictionary *actions;
@property (nonatomic) UIControlEvents capture;

-(void)performIBCallback:(id)sender;

@end

@implementation DCAUIControl
@synthesize actions;
@synthesize capture;

+(id)fieldWithType:(Class)type name:(NSString*)name label:(NSString*)label {
    DCAUIControl *ret = [[DCAUIControl alloc] initWithType:type name:name];
    ret.field.accessibilityLabel = label;
    return ret;
}

+(id)fieldWithType:(Class)type name:(NSString*)name label:(NSString*)label actions:(NSDictionary*)actions {
    DCAUIControl *ret = [DCAUIControl fieldWithType:type name:name label:label];
    ret.actions = [NSMutableDictionary dictionaryWithDictionary:actions];
    for(NSNumber *event in [actions allKeys]) {
        ret.capture |= event.intValue;
    }
    [(UIControl*)ret.field captureEvents:ret.capture];
    [actions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(UIControl*)ret.field addTarget:ret action:@selector(performIBCallback:) forControlEvents:(UIControlEvents)((NSNumber*)key).intValue];
    }];
    return ret;
}

-(id) initWithType:(Class)type name:(NSString*)name {
    if(self = [super init]) {
        self.capture = 0;
        self.actions = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) setCallback:(UICallback)callback forEvent:(UIControlEvents)event {
    self.capture |= event;
    [self.actions setObject:callback forKey:[NSNumber numberWithInt:event]];
    [(UIControl*)self.field captureEvents:self.capture];
    [(UIControl*)self.field addTarget:self action:@selector(performIBCallback:) forControlEvents:event];
}

-(void)performIBCallback:(UIControl*)sender {
    UICallback callback = (UICallback)[self.actions objectForKey:[NSNumber numberWithInt:sender.tag]];
    callback(sender);
}

@end