//
//  FormField.h
//  CarAccidentHelp
//
//  Created by Bion Oren on 12/21/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCAUIView.h"

typedef void (^UICallback)(UIControl *sender);

@interface DCAUIControl : DCAUIView

+(id)fieldWithType:(Class)type name:(NSString*)name label:(NSString*)label;
+(id)fieldWithType:(Class)type name:(NSString*)name label:(NSString*)label actions:(NSDictionary*)actions;

-(id) initWithType:(Class)type name:(NSString*)name;

-(void) setCallback:(UICallback)callback forEvent:(UIControlEvents)event;

@end