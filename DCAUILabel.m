//
//  DCAUILabel.m
//  CarAccidentHelp
//
//  Created by Bion Oren on 12/22/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import "DCAUILabel.h"

@implementation DCAUILabel
@synthesize field;
@synthesize font;
@synthesize textColor;

-(id)init {
    if(self = [super init]) {
        field = [[UILabel alloc] init];
        self.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setFont:(UIFont*)newFont {
    font = newFont;
    [(UILabel*)self.field setFont:newFont];
}

-(void)setTextColor:(UIColor*)newColor {
    textColor = newColor;
    [(UILabel*)self.field setTextColor:self.textColor];
}

-(void)format {
    [self.field setBackgroundColor:[UIColor clearColor]];
}

@end