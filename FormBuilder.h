//
//  FormBuilder.h
//  semaps
//
//  Created by Bion Oren on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCAUIView.h"

@interface FormBuilder : NSObject
{
    int width;
    int height;
    int top_padding;
    int left_padding;
    int bottom_padding;
    int right_padding;
    int fieldOffset;
    int elementPadding;
}

@property (nonatomic, strong, readonly) UIView *view;

- (id)initWithView:(UIView*)newView;
- (void)addObject:(DCAUIView*)obj withName:(NSString*)name;

@end
