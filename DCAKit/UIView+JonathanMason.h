//
//  UIView+JonathanMason.h
//  DCAKit
//
//  Created by Drew Crawford on 10/28/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JonathanMason)
/** Asks the delegate if editing should begin in the specified text view.
 @param animated Whether or not the view should be animated
 */
-(void) viewShouldBeginEditing:(int) animated;
@end
