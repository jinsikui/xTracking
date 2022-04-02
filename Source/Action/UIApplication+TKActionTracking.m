

#import "UIApplication+TKActionTracking.h"

#import "TKClassHooker.h"
#import "TKActionHelper.h"

@implementation UIApplication (TKActionTracking)

+ (void)load {
    // for tap of UIBarButtonItem or UITabBarItem or UIView
    [TKClassHooker exchangeOriginMethod:@selector(sendAction:to:from:forEvent:) newMethod:@selector(tk_sendAction:to:from:forEvent:) mclass:[UIApplication class]];
}

- (void)tk_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    [self tk_sendAction:action to:target from:sender forEvent:event];
    BOOL isPress = event.type == UIEventTypePresses;
    BOOL isTouch = event.type == UIEventTypeTouches;
    //  是否为点击
    if (!isPress && !isTouch) return;
    
    //  是否是view或baritem发起的
    BOOL isView = [sender isKindOfClass:[UIView class]];
    BOOL isBarItem = [sender isKindOfClass:[UIBarButtonItem class]] || [sender isKindOfClass:[UITabBarItem class]];
    if (!isView && !isBarItem) return;
    
    [TKActionHelper reportActionObjectIfNeed:sender];
}

@end
