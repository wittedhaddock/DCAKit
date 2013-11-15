//
//  GCD+DCA.c
//  DCAKit
//
//  Created by Drew Crawford on 10/22/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#include <stdio.h>
#include <dispatch/dispatch.h>
#include "GCD+DCA.h"

void dispatch_sleep(double timeInSeconds) {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, timeInSeconds * NSEC_PER_SEC);
    dispatch_semaphore_wait(sema, time);
    
}