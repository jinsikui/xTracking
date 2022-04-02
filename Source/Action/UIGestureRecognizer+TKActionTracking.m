

#import "UIGestureRecognizer+TKActionTracking.h"

#import "TKActionHelper.h"
#import "TKClassHooker.h"

@implementation UIGestureRecognizer (TKActionTracking)

+ (void)load {
    [TKClassHooker exchangeOriginMethod:@selector(initWithTarget:action:) newMethod:@selector(tk_initWithTarget:action:) mclass:[UIGestureRecognizer class]];
    [TKClassHooker exchangeOriginMethod:@selector(addTarget:action:) newMethod:@selector(tk_addTarget:action:) mclass:[UIGestureRecognizer class]];
}

- (instancetype)tk_initWithTarget:(id)target action:(SEL)action {
    [self tk_initWithTarget:target action:action];
    [self removeTarget:target action:action];
    [self addTarget:target action:action];
    return self;
}

- (void)tk_addTarget:(id)target action:(SEL)action {
    if ([self isKindOfClass:[UITapGestureRecognizer class]]
        || [self isKindOfClass:[UILongPressGestureRecognizer class]]) {
        [self tk_addTarget:self action:@selector(tk_trackGestureRecognizerAppClick:)];
    }
    [self tk_addTarget:target action:action];
}

- (void)tk_trackGestureRecognizerAppClick:(UIGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        [TKActionHelper reportActionObjectIfNeed:ges.view];
    }
}

@end


