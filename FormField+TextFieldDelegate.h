//
//  FormField+TextFieldDelegate.h
//  DCA-libs
//
//  Created by Bion Oren on 12/31/11.
//  Copyright (c) 2011 DrewCrawfordApps LLC. All rights reserved.
//

#import "FormField.h"

@interface FormField (TextFieldDelegate) <UITextFieldDelegate>

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

@end