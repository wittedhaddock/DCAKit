//
//  DCAUIView.h
//  CarAccidentHelp
//
//  Created by Bion Oren on 12/22/11.
//  Copyright (c) 2011 DrewCrawfordApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCAUIView : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong, readonly) UIView *field;

-(void)format;

@end