//
//  NSObject+KVOHelp.m
//  CoreDataHelp
//
//  Created by Drew Crawford on 2/14/13.
//
//

#import "NSObject+KVOHelp.h"
#import <objc/runtime.h>
static const char *observerKey = "ObserverKey";
@interface ObserverObj : NSObject {
    @public
    Observe block;
    __weak id observer_ref;
    NSString *_keyPath;
}
 
@end
@implementation ObserverObj

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!observer_ref) {
        [object removeObserver:self forKeyPath:keyPath];
        return;
    }
    block(observer_ref,object,keyPath,change,context);
}

@end
@implementation NSObject (KVOHelp)
-(void) addObserverWithRef:(id) observer_ref keypath:(NSString*) keypath options:(NSKeyValueObservingOptions) options context:(void*) context block:(Observe) block {
    ObserverObj *oldObserver =  (objc_getAssociatedObject(self, observerKey));
    if (oldObserver) [self removeObserver:oldObserver forKeyPath:oldObserver->_keyPath];
    ObserverObj *obj = [[ObserverObj alloc] init];
    obj->observer_ref = observer_ref;
    obj->block = block;
    obj->_keyPath = keypath;
    objc_setAssociatedObject(self, observerKey, obj, OBJC_ASSOCIATION_RETAIN);

    [self addObserver:obj forKeyPath:keypath options:options context:context];
}

- (void)removeObserverWithRef:(id)observer_ref keypath:(NSString *)keypath {
    ObserverObj *oldObserver =  (objc_getAssociatedObject(self, observerKey));
    if (oldObserver) {
       [self removeObserver:oldObserver forKeyPath:keypath];
        objc_setAssociatedObject(self, observerKey, Nil, OBJC_ASSOCIATION_RETAIN);
    }
    
}
@end
