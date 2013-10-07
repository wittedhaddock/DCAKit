//
//  UIView+AutoLayout.h
//  DCAKit
//
//  Created by Drew Crawford on 10/6/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)

/** Finds the constraint given the remote view and the direction (specified from the perspective of the receiver).
 
 If there is more than one constraint, which one you get is undefined.
 */
-(NSLayoutConstraint*) constraintMatchingView:(UIView*) other inDirection:(NSLayoutAttribute) direction;

/** This creates a constraint (or modifies an existing one) according to the parameters.  You must call [view setNeedsLayout] for the constraints be updated in the layout.
 
 @param view the view with which to constrain the receiver
 @param direction must be either leading, trailing, top, or bottom
 @param value a constant value for the constraint
 */
- (void)constrainWith:(UIView *)view inDirection:(NSLayoutAttribute)direction value:(int) value;

/** Creates (or modifies) a constraint according to the parameters.  You must call [view setNeedsLayout] for the constraint to be updated in the layout.
 
 @param direction must be leading, trailing, top, or bottom
 @param value a constant value for the constraint
 */
-(void) constrainWithSuperviewInDirection:(NSLayoutAttribute) direction value:(int) value;

-(void) constrainHeight:(int) value;

/**Apply constraints such that the view spreads to the full size of the superview*/
-(void) maximize;

@end
