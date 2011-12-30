//
//  DCAUITextField.m
//  CarAccidentHelp
//
//  Created by Bion Oren on 12/22/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCAUITextField.h"

@interface DCAUITextField ()

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end

@implementation DCAUITextField

-(void) format {
    [(UITextField*)self.field setBorderStyle:UITextBorderStyleRoundedRect];
    ((UITextField*)self.field).delegate = self;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
