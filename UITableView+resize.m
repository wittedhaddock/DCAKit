//
//  UITableView+resize.m
//  semaps
//
//  Created by Bion Oren on 7/29/11.
//  Copyright 2011 DrewCrawfordApps LLC. All rights reserved.
//

#import "UITableView+resize.h"

@implementation UITableView (resizable)

-(void)sizeToFit
{
    [super sizeToFit];
    
    int rows = [self.dataSource tableView:self numberOfRowsInSection:0];
    if(rows > 5)
    {
        rows = 5;
    }
    int height = rows*self.rowHeight;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end
