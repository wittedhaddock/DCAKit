//
//  FormField+TextFieldDelegate.m
//  DCA-libs
//
//  Created by Bion Oren on 12/31/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import "FormField+TextFieldDelegate.h"

@interface FormField ()

-(void)setView:(UIView*)targetView moveToY:(NSInteger)y;

@end

@implementation FormField (TextFieldDelegate)

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#define THRESHOLD 190
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"y: %f, h: %f", textField.frame.origin.y, textField.frame.size.height);
    CGPoint offset = [self.field convertPoint:self.field.frame.origin toView:nil];
    if(offset.y > THRESHOLD) {
        [self setView:textField.window.rootViewController.view moveToY:THRESHOLD-offset.y];
    }
    return YES;
}
#undef THRESHOLD

-(void)setView:(UIView*)targetView moveToY:(NSInteger)y;
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rect = targetView.frame;
    rect.origin.y = y;
    targetView.frame = rect;
    
    [UIView commitAnimations];
}

@end