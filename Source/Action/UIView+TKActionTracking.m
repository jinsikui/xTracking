

#import "UIView+TKActionTracking.h"

#import "TKActionHelper.h"
#import "TKClassHooker.h"

#import <objc/runtime.h>

@implementation UIView (TKActionTracking)

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

@implementation UITableView (TKActionTracking)

+ (void)load {
    NSString *selPart1 = @"_userSelectRowAtPending";
    NSString *selPart2 = @"SelectionIndexPath:";
    SEL selectMethod = NSSelectorFromString([NSString stringWithFormat:@"%@%@", selPart1, selPart2]);
    [TKClassHooker exchangeOriginMethod:selectMethod newMethod:@selector(tk_userSelectRowAtPendingSelectionIndexPath:) mclass:[UITableView class]];
}

- (void)tk_userSelectRowAtPendingSelectionIndexPath:(NSIndexPath *)indexPath {
    [self tk_userSelectRowAtPendingSelectionIndexPath:indexPath];
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [TKActionHelper reportActionObjectIfNeed:cell];
}

@end

@implementation UICollectionView (TKActionTracking)

+ (void)load {
    NSString *selPart1 = @"_userSelectItem";
    NSString *selPart2 = @"AtIndexPath:";
    SEL selectMethod = NSSelectorFromString([NSString stringWithFormat:@"%@%@", selPart1, selPart2]);
    [TKClassHooker exchangeOriginMethod:selectMethod newMethod:@selector(tk_userSelectItemAtIndexPath:) mclass:[UICollectionView class]];
}

- (void)tk_userSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self tk_userSelectItemAtIndexPath:indexPath];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
    [TKActionHelper reportActionObjectIfNeed:cell];
}

@end
