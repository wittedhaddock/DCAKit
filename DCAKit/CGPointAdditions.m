//
//  CGPointAdditions.c
//  DCAKit
//
//  Created by Drew Crawford on 12/10/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#include <stdio.h>
#import "CGPointAdditions.h"
#include <math.h>
double CGPointDistanceFromPoint(CGPoint p1,CGPoint p2) {
    double distance = ({double d1 = p1.x - p2.x, d2 = p1.y - p2.y; sqrt(d1 * d1 + d2 * d2); });
    return distance;
}