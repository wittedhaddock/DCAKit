//
//  GCD+DCA.h
//  DCAKit
//
//  Created by Drew Crawford on 10/22/13.
//  Copyright (c) 2013 DrewCrawfordApps. All rights reserved.
//

#ifndef DCAKit_GCD_DCA_h
#define DCAKit_GCD_DCA_h

/**A better sleep.
 
 This sleep is much more likely to do what you want with the other jobs/threads that should still be running than the ordinary kind.  Expecting things to happen while you sleep that aren't happening?  With this sleep, it does.
 
 It also supports a double resolution parameter.
 
 It's also implemented in pure GCD.
 
 */
void dispatch_sleep(double timeInSeconds);

#endif
