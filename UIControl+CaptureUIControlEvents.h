// The MIT License
//
// Copyright (c) 2010 Juan Batiz-Benet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//------------------------------------------------------------------------------

// UIControl+CaptureUIControlEvents Category
// Author: Juan Batiz-Benet
// github gist at: http://gist.github.com/513796

// PROBLEM: upon firing, UIControlEvents are not passed into the target action
// assigned to the particular event. This would be useful in order to have only
// one action that switches based on the UIControlEvent fired.
//
// SOLUTION: add a way to store the UIControlEvent triggered in the UIEvent.
//
// PROBLEM: But we cannot override private APIs, so:
// (Worse) solution: have the UIControl store the UIControlEvent last fired.
//
// The UIControl documentation states that:
// > When a user touches the control in a way that corresponds to one or more
// > specified events, UIControl sends itself sendActionsForControlEvents:.
// > This results in UIControl sending the action to UIApplication in a
// > sendAction:to:from:forEvent: message.
//
// One would think that sendActionsForControlEvents: can be overridden (or
// subclassed) to store the flag, but it is not so. It seems that
// sendActionsForControlEvents: is mainly there for clients to trigger events
// programatically.
//
// Instead, I had to set up a scheme that registers an action for each control
// event that one wants to track. I decided not to track all the events (or in
// all UIControls) for performance and ease of use.
//
// Example Usage:
// // (on setup)
// UIControlEvents capture = UIControlEventTouchDown;
// capture |= UIControlEventTouchDown;
// capture |= UIControlEventTouchUpInside;
// capture |= UIControlEventTouchUpOutside;
// [myControl captureEvents:capture];
// [myControl addTarget:self action:@selector(touch:) forControlEvents:capture];
//
// ...
// // the target action
// - (void) touch:(UIControl *)sender {
//   UIColor *color = [UIColor clearColor];
//   switch (sender.tag) {
//     case UIControlEventTouchDown: color = [UIColor redColor]; break;
//     case UIControlEventTouchUpInside: color = [UIColor blueColor]; break;
//     case UIControlEventTouchUpOutside: color = [UIColor redColor]; break;
//   }
//   sender.backgroundColor = color;
// }

//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface UIControl (CaptureUIControlEvents)
- (void) captureEvents:(UIControlEvents)controlEvents;
@end
