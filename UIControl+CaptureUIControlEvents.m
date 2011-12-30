// The MIT License
//
// Copyright (c) 2010 Juan Batiz-Benet (jbenet@cs.stanford.edu)
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

// Hmmm one method for each UIControlEvent... so gross. I can hear the purist
// inside me screaming: ``You're doing it wrong!''

#import "UIControl+CaptureUIControlEvents.h"

@implementation UIControl (CaptureUIControlEvents)

- (void) captureUIControlEventTouchDown {
  self.tag = UIControlEventTouchDown;
}

- (void) captureUIControlEventTouchDownRepeat {
  self.tag = UIControlEventTouchDownRepeat;
}

- (void) captureUIControlEventTouchDragInside {
  self.tag = UIControlEventTouchDragInside;
}

- (void) captureUIControlEventTouchDragOutside {
  self.tag = UIControlEventTouchDragOutside;
}

- (void) captureUIControlEventTouchDragEnter {
  self.tag = UIControlEventTouchDragEnter;
}

- (void) captureUIControlEventTouchDragExit {
  self.tag = UIControlEventTouchDragExit;
}

- (void) captureUIControlEventTouchUpInside {
  self.tag = UIControlEventTouchUpInside;
}

- (void) captureUIControlEventTouchUpOutside {
  self.tag = UIControlEventTouchUpOutside;
}

- (void) captureUIControlEventTouchCancel {
  self.tag = UIControlEventTouchCancel;
}

- (void) captureUIControlEventValueChanged {
  self.tag = UIControlEventValueChanged;
}

- (void) captureUIControlEventEditingDidBegin {
  self.tag = UIControlEventEditingDidBegin;
}

- (void) captureUIControlEventEditingChanged {
  self.tag = UIControlEventEditingChanged;
}

- (void) captureUIControlEventEditingDidEnd {
  self.tag = UIControlEventEditingDidEnd;
}

- (void) captureUIControlEventEditingDidEndOnExit {
  self.tag = UIControlEventEditingDidEndOnExit;
}

- (SEL) captureActionForUIControlEvent:(UIControlEvents)controlEvent
{
  switch (controlEvent) {
    case UIControlEventTouchDown:
      return @selector(captureUIControlEventTouchDown);
    case UIControlEventTouchDownRepeat:
      return @selector(captureUIControlEventTouchDownRepeat);
    case UIControlEventTouchDragInside:
      return @selector(captureUIControlEventTouchDragInside);
    case UIControlEventTouchDragOutside:
      return @selector(captureUIControlEventTouchDragOutside);
    case UIControlEventTouchDragEnter:
      return @selector(captureUIControlEventTouchDragEnter);
    case UIControlEventTouchDragExit:
      return @selector(captureUIControlEventTouchDragExit);
    case UIControlEventTouchUpInside:
      return @selector(captureUIControlEventTouchUpInside);
    case UIControlEventTouchUpOutside:
      return @selector(captureUIControlEventTouchUpOutside);
    case UIControlEventTouchCancel:
      return @selector(captureUIControlEventTouchCancel);
    case UIControlEventValueChanged:
      return @selector(captureUIControlEventValueChanged);
    case UIControlEventEditingDidBegin:
      return @selector(captureUIControlEventEditingDidBegin);
    case UIControlEventEditingChanged:
      return @selector(captureUIControlEventEditingChanged);
    case UIControlEventEditingDidEnd:
      return @selector(captureUIControlEventEditingDidEnd);
    case UIControlEventEditingDidEndOnExit:
      return @selector(captureUIControlEventEditingDidEndOnExit);
  }
  return nil; // shouldnt get here.
}

- (void) considerCapturing:(UIControlEvents)event
          forControlEvents:(UIControlEvents)controlEvents
{
  SEL captureAction = [self captureActionForUIControlEvent:event];
  if (captureAction != nil && controlEvents & event)
    [self addTarget:self action:captureAction forControlEvents:event];
}

- (void) captureEvents:(UIControlEvents)events {
  for (UIControlEvents event = 0x01; event; event <<= 1)
    [self considerCapturing:event forControlEvents:events];
}

@end