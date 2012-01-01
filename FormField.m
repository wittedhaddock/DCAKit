//
//  FormField.m
//  DCA-libs
//
//  Created by Bion Oren on 12/31/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import "FormField.h"
#import "UIControl+CaptureUIControlEvents.h"

#define TOP(rect) rect.origin.x
#define RIGHT(rect) rect.origin.y
#define BOTTOM(rect) rect.size.width
#define LEFT(rect) rect.size.height

@interface FormField ()

@property (nonatomic, strong) NSMutableDictionary *callbacks;
@property (nonatomic) UIControlEvents captureEvents;

-(IBAction)controlCallback:(id)sender;

@end

@implementation FormField
@synthesize field;
@synthesize label;
@synthesize callbacks;
@synthesize captureEvents;

+(FormField*)field:(Class)fieldType {
    FormField *ret = [[FormField alloc] initWithClass:fieldType];
    
    return ret;
}

+(FormField*)field:(Class)fieldType WithLabel:(NSString*)label {
    FormField *ret = [FormField field:fieldType];
    ret.label = [[UILabel alloc] init];
    ret.label.text = label;
    
    return ret;
}

-(id)initWithClass:(Class)fieldType {
    if(self = [super init]) {
        self.field = [[fieldType alloc] init];
        self.label = nil;
        
        if([self.field isKindOfClass:[UIControl class]]) {
            self.callbacks = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

-(void)layoutInWidth:(int)width xoffset:(int)xoffset yoffset:(int)yoffset padding:(CGRect)padding elementPadding:(CGRect)elementPadding {
    xoffset += LEFT(elementPadding);
    
    if(self.label) {
        [self.label sizeToFit];
        self.label.frame = CGRectMake(xoffset, yoffset, self.label.frame.size.width, self.label.frame.size.height);
        xoffset += self.label.frame.size.width + RIGHT(elementPadding) + LEFT(elementPadding);
    }
    
    [self.field sizeToFit];
    int elementHeight = self.field.frame.size.height;
    if(elementHeight <= 0) {
        elementHeight = self.label.frame.size.height;
    }
    self.field.frame = CGRectMake(xoffset, yoffset, width-(xoffset + RIGHT(elementPadding) + RIGHT(padding)), elementHeight);
}

#pragma mark - UIControl callbacks

-(void)addUIControlAction:(formActionCallback)block forEvent:(UIControlEvents)event {
    NSAssert([self.field isKindOfClass:[UIControl class]], @"Can't add a UIControl event to %@, which does not inherit UIControl", self.field);
    self.captureEvents |= event;
    [(UIControl*)self.field captureEvents:self.captureEvents];
    [self.callbacks setObject:[block copy] forKey:[NSNumber numberWithInt:event]];
    [(UIControl*)self.field addTarget:self action:@selector(controlCallback:) forControlEvents:event];
}

-(void)clearUIControlEvents {
    [(UIControl*)self.field removeTarget:self action:nil forControlEvents:self.captureEvents];
    [(UIControl*)self.field captureEvents:0];
    self.captureEvents = 0;
    [self.callbacks removeAllObjects];
}

-(void)controlCallback:(id)sender {
    formActionCallback callback = (formActionCallback)[self.callbacks objectForKey:[NSNumber numberWithInt:((UIControl*)sender).tag]];
    callback((UIControl*)sender);
}

@end