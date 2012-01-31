//
//  FormBuilder.h
//  semaps
//
//  Created by Bion Oren on 7/29/11.
//  Copyright 2011 DrewCrawfordApps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormField.h"

@interface FormBuilder : NSObject

@property (nonatomic) int width;
@property (nonatomic) int height;
//top, right, bottom, left - same as in CSS
@property (nonatomic) CGRect padding;
@property (nonatomic) CGRect elementPadding;

@property (nonatomic, strong, readonly) UIView *view;

- (id)init;
- (id)initWithView:(UIView*)newView;

- (void)addField:(FormField*)obj;
- (void)reset;
- (void)layout;

@end
