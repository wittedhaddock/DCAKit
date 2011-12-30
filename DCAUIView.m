//
//  DCAUIView.m
//  CarAccidentHelp
//
//  Created by Bion Oren on 12/22/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

/*+(void)formatTable:(UITableView*)field
 {
 field.rowHeight = 44;
 field.sectionHeaderHeight = 22;
 field.sectionFooterHeight = 22;
 }*/

#import "DCAUIView.h"

@implementation DCAUIView
@synthesize field;
@synthesize backgroundColor;

-(id) init {
    if(self = [super init]) {
        self.backgroundColor = self.field.backgroundColor;
    }
    return self;
}

-(void)setBackgroundColor:(UIColor*)newBackgroundColor {
    backgroundColor = newBackgroundColor;
    self.field.backgroundColor = backgroundColor;
}

-(void)format {
    [self.field setContentStretch:CGRectMake(0, 0, 1, 1)];
}

@end