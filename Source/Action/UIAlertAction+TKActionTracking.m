

#import "UIAlertAction+TKActionTracking.h"
#import "TKClassHooker.h"
#import "TKActionHelper.h"
#import <objc/runtime.h>

@implementation UIAlertAction (TKActionTracking)

+ (void)load {
    [TKClassHooker exchangeClassOriginMethod:@selector(actionWithTitle:style:handler:) newMethod:@selector(tk_actionWithTitle:style:handler:) mclass:[UIAlertAction class]];
}

#pragma mark - hook method

+ (instancetype)tk_actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction * _Nonnull))handler {
    void(^handlerNew)(UIAlertAction *action) = ^(UIAlertAction *action){
        handler ? handler(action) :0;
        [TKActionHelper reportActionObjectIfNeed:action];
    };
    
    return [self tk_actionWithTitle:title style:style handler:handlerNew];
}

#pragma mark - ITKActionObject

- (void)tk_setActionContextWithTrackingId:(NSString *_Nullable)trackingId
                                 userData:(id _Nullable)userData {
    [TKActionHelper setActionContextToObject:self
                                  trackingId:(NSString*_Nullable)trackingId
                                    userData:(id _Nullable)userData];
}

- (void)tk_clearActionContext{
    [TKActionHelper clearActionContextForObject:self];
}

- (TKActionContext *)tk_actionContext {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTk_actionContext:(TKActionContext *)tk_actionContext {
    objc_setAssociatedObject(self, @selector(tk_actionContext), tk_actionContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TKActionContextProvider)tk_actionContextProvider {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTk_actionContextProvider:(TKActionContextProvider)tk_actionContextProvider {
    objc_setAssociatedObject(self, @selector(tk_actionContextProvider), tk_actionContextProvider, OBJC_ASSOCIATION_COPY);
}

@end
