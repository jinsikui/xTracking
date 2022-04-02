

#import "TKActionHelper.h"
#import "TKActionTracking.h"
#import "UIView+TKActionTracking.h"
#import "UIAlertAction+TKActionTracking.h"

@implementation TKActionHelper

+ (void)reportActionObjectIfNeed:(id)object {
    if ([object conformsToProtocol:@protocol(ITKActionObject)]) {
        id<ITKActionObject> obj = (id<ITKActionObject>)object;
        TKActionContext *context;
        //  是否有provider
        if (obj.tk_actionContextProvider) {
            __weak typeof(object) weakObj = object;
            context = obj.tk_actionContextProvider(weakObj);
        } else if (obj.tk_actionContext) {
            context = obj.tk_actionContext;
        }
        if (context) {
            [[TKActionTracking shared] sendActionForSender:obj context:context];
        }
    }
}

+ (void)setActionContextToObject:(id)object
                      trackingId:(NSString*_Nullable)trackingId
                        userData:(id _Nullable)userData {
    
    if (![object conformsToProtocol:@protocol(ITKActionObject)]) {
        return;
    }
    id<ITKActionObject> obj = (id<ITKActionObject>)object;
    TKActionContext *context = [TKActionContext new];
    context.trackingId = trackingId;
    context.userData = userData;
    obj.tk_actionContext = context;
}

+ (void)clearActionContextForObject:(id)object {
    if (![object conformsToProtocol:@protocol(ITKActionObject)]) {
        return;
    }
    id<ITKActionObject> obj = (id<ITKActionObject>)object;
    obj.tk_actionContext = nil;
    obj.tk_actionContextProvider = nil;
}

@end
