//
//  NSObject+KVOHelp.h
//  CoreDataHelp
//
//  Created by Drew Crawford on 2/14/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (KVOHelp)
typedef void(^Observe)(id observer_ref, id object, NSString *keyPath, NSDictionary *change, void *context);

/**
 Blocks-based KVO.  
 
 1) If you follow the warning, your observer stops when the observer_ref is cleaned up automatically.  We also stop when the future is cleaned up.
 2) Currently there can only be one block-based observer on an object at a time...  Calling this again replaces the existing observer.  This is convenient e.g. for UICollectionViews and other flywheel-based views. 
 
 @param observer_ref Probably self.  It's a bug to retain self in your block, so we pass you a special version you can use called observer_ref.
 
 @warning Don't get capture a strong reference either to self or to the object in your block; this leads to weird memory issues.  Instead, use the values that are helpfully passed in.*/
-(void) addObserverWithRef:(id) observer_ref keypath:(NSString*) keypath options:(NSKeyValueObservingOptions) options context:(void*) context block:(Observe) block;

-(void) removeObserverWithRef:(id) observer_ref keypath:(NSString*) keypath;
@end
