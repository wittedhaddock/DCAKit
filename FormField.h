//
//  FormField.h
//  DCA-libs
//
//  Created by Bion Oren on 12/31/11.
//  Copyright (c) 2011 DrewCrawfordApps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^formActionCallback)(UIControl *sender);

@interface FormField : NSObject

@property (nonatomic, strong) UIView *field;
@property (nonatomic, strong) UILabel *label;

+(FormField*)field:(Class)fieldType;
+(FormField*)field:(Class)fieldType WithLabel:(NSString*)label;
-(id)initWithClass:(Class)fieldType;

-(void)addUIControlAction:(formActionCallback)block forEvent:(UIControlEvents)event;

-(void)layoutInWidth:(int)width xoffset:(int)xoffset yoffset:(int)yoffset padding:(CGRect)padding elementPadding:(CGRect)elementPadding;

@end