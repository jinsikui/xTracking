

#import "UIBarButtonItem+TKActionTracking.h"
#import <objc/runtime.h>

#import "TKActionHelper.h"

@implementation UIBarButtonItem (TKActionTracking)

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
