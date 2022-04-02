

#import "TKClassHooker.h"
#import <objc/runtime.h>

@implementation TKClassHooker

+ (void)exchangeOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass{
    Method originalMethod = class_getInstanceMethod(mclass, originSEL);
    Method newMethod = class_getInstanceMethod(mclass, newSEL);
    
    BOOL ret = class_addMethod(mclass,originSEL,
                    method_getImplementation(newMethod),
                    method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(mclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass{
    mclass = object_getClass(mclass);
    
    Method originalMethod = class_getClassMethod(mclass, originSEL);
    Method newMethod = class_getClassMethod(mclass, newSEL);
    
    BOOL ret = class_addMethod(mclass,originSEL,
                               method_getImplementation(newMethod),
                               method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(mclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
