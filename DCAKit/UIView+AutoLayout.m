//
//  UIView+AutoLayout.m
//  DCAKit
//
//  Created by Drew Crawford on 10/6/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#import "UIView+AutoLayout.h"

/**Returns the inverse of the given direction (e.g. trailing == leading, etc.) for layout applications.*/
NSLayoutAttribute naturalInverse(NSLayoutAttribute input);
NSLayoutAttribute naturalInverse(NSLayoutAttribute input) {
    switch(input) {
        case NSLayoutAttributeLeading:
            return NSLayoutAttributeTrailing;
        case NSLayoutAttributeBottom:
            return NSLayoutAttributeTop;
        case NSLayoutAttributeLeft:
            return NSLayoutAttributeRight;
        case NSLayoutAttributeTop:
            return NSLayoutAttributeBottom;
        case NSLayoutAttributeRight:
            return NSLayoutAttributeLeft;
        case NSLayoutAttributeTrailing:
            return NSLayoutAttributeLeading;
        default:
            NSCAssert(NO, @"Unknown layout attribute %d",input);
    }
    return NSLayoutAttributeNotAnAttribute;
}

@implementation UIView (AutoLayout)
- (NSLayoutConstraint*)constraintMatchingView:(UIView *)other inDirection:(NSLayoutAttribute)direction {
    NSLog(@"Searching for constraint between %p and %p in direction %d",self,other,direction);
    for(NSLayoutConstraint *constraint in self.constraints) {
        NSLog(@"Constraint between %p and %p in direction %d or %d",constraint.firstItem,constraint.secondItem,constraint.firstAttribute,constraint.secondAttribute);
        if (constraint.firstItem==other && constraint.secondItem==self && constraint.secondAttribute==direction) {
            return constraint;
        }
        else if (constraint.firstItem==self && constraint.secondItem==other && constraint.firstAttribute==direction) {
            return constraint;
        }
    }
    return nil;
}

- (void)constrainWith:(UIView *)view inDirection:(NSLayoutAttribute)direction value:(int) value {
    NSLayoutConstraint *constraint = [self constraintMatchingView:view inDirection:direction];
    if (constraint) [self removeConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:direction relatedBy:NSLayoutRelationEqual toItem:view attribute:naturalInverse(direction) multiplier:1.0 constant:value];
    [self addConstraint:constraint];
}

- (void)constrainWithSuperviewInDirection:(NSLayoutAttribute)direction value:(int)value {
    NSLayoutConstraint *constraint = [self.superview constraintMatchingView:self inDirection:direction];
    if (constraint) [self removeConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self.superview attribute:direction relatedBy:NSLayoutRelationEqual toItem:self attribute:direction multiplier:1.0 constant:value];
    [self.superview addConstraint:constraint];
}

-(void) constrainHeight:(int) value {
    NSLayoutConstraint *constraint = [self constraintMatchingView:nil inDirection:NSLayoutAttributeHeight];
    if (constraint) [self removeConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:value];
    [self addConstraint:constraint];

}

- (void)maximize {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:@{@"self":self}]];
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" options:0 metrics:nil views:@{@"self":self}]];

}

@end
