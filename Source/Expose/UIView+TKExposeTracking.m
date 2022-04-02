

#import "UIView+TKExposeTracking.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TKClassHooker.h"
#import "TKExposeTracking.h"
#if __has_include(<KVOController/KVOController.h>)
#import <KVOController/KVOController.h>
#else
#import "KVOController.h"
#endif

@interface UIView ()

///  自己或父view为hidden时，此值都为true
@property (nonatomic, assign) BOOL tk_isHidden;
///  自己或父view的alpha = 0时，此值都为true
@property (nonatomic, assign) BOOL tk_isAlpha0;
///  重新计算visibleRect的触发参数，一旦修改此参数，以这个view为根的所有子孙view中需要自动打点的都会重新计算visibleRect
@property (nonatomic, assign) NSInteger tk_layoutTrigger;
///  当前view在window上显示的区域
@property (nonatomic, assign) CGRect tk_visibleRect;
///  当前view对其子view进行clip的区域(相对于window)，
///  如果当前view.clipToBounds == true, self.tk_clipRect := superView.tk_clipRect.intersect(self.tk_visibleRect)，
///  如果当前view.clipToBounds == false, self.tk_clipRect := superView.tk_clipRect
///  默认值为(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)
@property (nonatomic, assign) CGRect tk_clipRect;
///  是否正在屏幕上显示 (通过显示规则计算出的结果，可能显示在屏幕上了，但是显示比例不够，这个值会为false)
@property (nonatomic, assign, readwrite) BOOL tk_isValidVisible;
///  当前view是否在屏幕上可见 (显示多少都算，会考虑父view的位置，但是不会考虑是否被兄弟view遮挡)
@property (nonatomic, assign) BOOL tk_isVisible;
///  当前view是否参与自动曝光计算（设置了exposeContext或者是其祖先view）
@property (nonatomic, assign) BOOL tk_isExposeActive;
///  当前view参与曝光的直接子view集合
@property (nonatomic, strong, readonly) NSHashTable<UIView *> *tk_exposeSubviews;
///  监听self.layer.hidden/opacity/masksToBounds属性的改变
@property (nonatomic, strong) FBKVOController *tk_kvo;

@end

@implementation UIView (TKAutoExpose)

+ (void)load {
    //  method hook
    // layoutSubviews方法是计算view相对于window的visibleRect最合适的时机，系统调用layoutSubviews时view的frame已经有值了，即使autolayout情况下也是如此
    // 为何已经hook了UIView的layoutSubviews方法，还要hook UITableView和UIButton的？原因在于UITableView和UIButton重写了layoutSubviews方法，并且在其实现中没有调super.layoutSubviews()
    // 导致交换UIView的layoutSubviews方法对UITableView和UIButton不会起作用
    [TKClassHooker exchangeOriginMethod:@selector(layoutSubviews) newMethod:@selector(tk_layoutSubviews) mclass:[UIView class]];
    [TKClassHooker exchangeOriginMethod:@selector(layoutSubviews) newMethod:@selector(tk_UITableView_layoutSubviews) mclass:[UITableView class]];
    [TKClassHooker exchangeOriginMethod:@selector(layoutSubviews) newMethod:@selector(tk_UIButton_layoutSubviews) mclass:[UIButton class]];
    
    // 因为visibleRect和clipRect是相对于window的，此时需要重新计算
    [TKClassHooker exchangeOriginMethod:@selector(didMoveToWindow) newMethod:@selector(tk_didMoveToWindow) mclass:[UIView class]];
    // UILayoutContainerView is UINavigationController.view.class
    [TKClassHooker exchangeOriginMethod:@selector(didMoveToWindow) newMethod:@selector(tk_UILayoutContainerView_didMoveToWindow) mclass:NSClassFromString(@"UILayoutContainerView")];
    
    // 此时已经确认添加至superview了，初始化相关属性
    [TKClassHooker exchangeOriginMethod:@selector(didMoveToSuperview) newMethod:@selector(tk_didMoveToSuperview) mclass:[UIView class]];
    // 此时self.superview还是旧的(可能为nil)，方法的参数是新的superview(移除时为nil)，这样就可以通知旧的superview子view被添加或移除，从而更新isExposeActive
    [TKClassHooker exchangeOriginMethod:@selector(willMoveToSuperview:) newMethod:@selector(tk_willMoveToSuperview:) mclass:[UIView class]];
    
    // 监听frame觉得不是很好的选择，但也没有别的办法，
    // 为何要监听frame？因为很多时候设置frame不会触发layoutSubviews，尤其当frame.size不改变时，即使设置父view的frame时改变了size，依然有可能不会触发子view的layoutSubviews方法（比如子view是label时很有可能这样）
    [TKClassHooker exchangeOriginMethod:@selector(setFrame:) newMethod:@selector(tk_setFrame:) mclass:[UIView class]];
    [TKClassHooker exchangeOriginMethod:@selector(setContentOffset:) newMethod:@selector(tk_setContentOffset:) mclass:[UIScrollView class]];
}

#pragma mark - hook method


- (void)tk_setContentOffset:(CGPoint)offset{
    CGPoint old = ((UIScrollView*)self).contentOffset;
    [self tk_setContentOffset:offset];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    @synchronized (self.tk_exposeSubviews) {
        for(UIView *view in self.tk_exposeSubviews){
            [view tk_superViewContentOffsetDidChangedFrom:old to:offset];
        }
    }
}

- (void)tk_setFrame:(CGRect)frame{
    CGRect old = self.frame;
    [self tk_setFrame:frame];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_selfFrameDidChangedFrom:old to:frame];
}

- (void)_tk_layoutSubviews {
    [self tk_resetVisibleRect];
    [self tk_resetClipRect];
    [self tk_resetIsVisible];
}

- (void)tk_layoutSubviews {
    [self tk_layoutSubviews];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self _tk_layoutSubviews];
}

- (void)tk_UITableView_layoutSubviews {
    [self tk_UITableView_layoutSubviews];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self _tk_layoutSubviews];
}

- (void)tk_UIButton_layoutSubviews {
    [self tk_UIButton_layoutSubviews];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self _tk_layoutSubviews];
}

- (void)_tk_didMoveToWindow {
    [self tk_resetVisibleRect];
    [self tk_resetClipRect];
    [self tk_resetIsVisible];
}

- (void)tk_didMoveToWindow {
    [self tk_didMoveToWindow];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self _tk_didMoveToWindow];
}

- (void)tk_UILayoutContainerView_didMoveToWindow {
    [self tk_UILayoutContainerView_didMoveToWindow];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self _tk_didMoveToWindow];
}

-(void)tk_willMoveToSuperview:(UIView *)newSuperview{
    [self tk_willMoveToSuperview:newSuperview];
    if (!TKExposeTracking.shared.isEnabled) return;
    if(newSuperview){
        if(self.tk_isExposeActive){
            if(self.superview && self.superview != newSuperview){
                [self.superview tk_removeExposeSubview:self];
            }
            [newSuperview tk_addExposeSubview:self];
        }
    }
    else{
        if(self.tk_isExposeActive){
            if(self.superview){
                [self.superview tk_removeExposeSubview:self];
            }
        }
    }
}

- (void)tk_didMoveToSuperview {
    [self tk_didMoveToSuperview];
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetExposeProperties];
}

#pragma mark - observe func

- (void)tk_superViewClipRectDidChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetVisibleRect];
    [self tk_resetClipRect];
    [self tk_resetIsVisible];
}

- (void)tk_superViewHiddenDidChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetIsHidden];
    [self tk_resetIsVisible];
}

- (void)tk_superViewAlphaDidChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetIsAlpha0];
    [self tk_resetIsVisible];
}

- (void)tk_superViewLayoutTriggerDidChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetVisibleRect];
    [self tk_resetClipRect];
    [self tk_resetIsVisible];
    self.tk_layoutTrigger = (self.tk_layoutTrigger + 1) % 2;
}

- (void)tk_superViewContentOffsetDidChangedFrom:(CGPoint)offsetOld to:(CGPoint)offsetNew{
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    
    BOOL offsetChanged = NO;
    // 如果frame变化不达到1，不触发
    if (offsetOld.y != offsetNew.y) {
        if (fabs(floor(offsetOld.y) - floor(offsetNew.y)) >= 1.f) {
            offsetChanged = YES;
        }
    }
    if (!offsetChanged){
        if (offsetOld.x != offsetNew.x) {
            if (fabs(floor(offsetOld.x) - floor(offsetNew.x)) >= 1.f) {
                offsetChanged = YES;
            }
        }
    }
    if (!offsetChanged) {
        return;
    }
    [self tk_resetVisibleRect];
    [self tk_resetClipRect];
    [self tk_resetIsVisible];
    self.tk_layoutTrigger = (self.tk_layoutTrigger + 1) % 2;
}

- (void)tk_selfLayerMasksToBoundsChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetClipRect];
}

- (void)tk_selfViewHiddenDidChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetIsHidden];
    [self tk_resetIsVisible];
}

- (void)tk_selfViewAlphaDidChanged {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    [self tk_resetIsAlpha0];
    [self tk_resetIsVisible];
}

- (void)tk_selfFrameDidChangedFrom:(CGRect)oFrame to:(CGRect)nFrame {
    if (!TKExposeTracking.shared.isEnabled || !self.tk_isExposeActive) return;
    // 如果frame没变，不重新计算visible
    if (CGRectEqualToRect(nFrame, oFrame)) {
        return;
    }
    /*
     这里为什么要asyncMain？是因为测试发现setFrame后如果立即计算visibleRect，convertRect:toView:方法返回的结果有可能不对导致bug
     我们基本上可以肯定在layoutSubview中调用convertRect:toView:结果一定是对的，但setFrame时就不一定了
    **/
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tk_resetVisibleRect];
        [self tk_resetClipRect];
        [self tk_resetIsVisible];
        self.tk_layoutTrigger = (self.tk_layoutTrigger + 1)%2;
    });
}

#pragma mark - private

- (void)tk_resetExposeProperties {
    [self tk_resetIsHidden];
    [self tk_resetIsAlpha0];
    [self tk_resetVisibleRect];
    [self tk_resetClipRect];
    [self tk_resetIsVisible];
}

- (void)tk_clearExposeKVO{
    if(self.tk_kvo){
        [self.tk_kvo unobserveAll];
        self.tk_kvo = nil;
    }
}

- (void)tk_setupExposeKVO{
    // 先释放之前的观察
    [self tk_clearExposeKVO];
    // kvo不会持有self，里面的observer属性是weak的
    self.tk_kvo = [[FBKVOController alloc] initWithObserver:self retainObserved:true];
    // 监听自己self->kvo->self.layer，没有循环引用
    [self.tk_kvo observe:self.layer keyPath:@"masksToBounds" options:(NSKeyValueObservingOptionNew) action:@selector(tk_selfLayerMasksToBoundsChanged)];
    [self.tk_kvo observe:self.layer keyPath:@"hidden" options:(NSKeyValueObservingOptionNew) action:@selector(tk_selfViewHiddenDidChanged)];
    [self.tk_kvo observe:self.layer keyPath:@"opacity" options:(NSKeyValueObservingOptionNew) action:@selector(tk_selfViewAlphaDidChanged)];
}

- (void)tk_resetIsHidden {
    BOOL tk_isHidden;
    if (self.superview) {
        tk_isHidden = self.superview.tk_isHidden || self.hidden;
    } else {
        tk_isHidden = self.hidden;
    }
    if (tk_isHidden != self.tk_isHidden) {
        self.tk_isHidden = tk_isHidden;
    }
}

- (void)tk_resetIsAlpha0 {
    BOOL spAlpha0;
    BOOL tk_isAlpha0;
    if (self.superview) {
        spAlpha0 = self.superview.tk_isAlpha0;
        tk_isAlpha0 = spAlpha0 || !self.alpha;
    } else {
        tk_isAlpha0 = self.alpha == 0;
    }
    if (self.tk_isAlpha0 != tk_isAlpha0) {
        self.tk_isAlpha0 = tk_isAlpha0;
    }
}

- (void)tk_resetVisibleRect {
    CGRect visibleRect;
    if(!self.window){
        visibleRect = CGRectZero;
    }
    else{
        visibleRect = [self convertRect:self.bounds toView:nil]; // 计算view相对于window的rect
        if (self.window) {
            visibleRect = CGRectIntersection(visibleRect, self.window.bounds);
        }
        if (self.superview) {
            visibleRect = CGRectIntersection(visibleRect, self.superview.tk_clipRect);
        }
    }
    if (!CGRectEqualToRect(visibleRect, self.tk_visibleRect)) {
        self.tk_visibleRect = visibleRect;
    }
}

- (void)tk_resetClipRect {
    CGRect clipRect;
    if (!self.superview) {
        if (self.clipsToBounds) {
           clipRect = CGRectZero;
       } else {
           clipRect = CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX);
       }
    } else {
        if (self.clipsToBounds) {
           clipRect = CGRectIntersection(self.superview.tk_clipRect, self.tk_visibleRect);
       } else {
           clipRect = self.superview.tk_clipRect;
       }
    }
    if (!CGRectEqualToRect(clipRect, self.tk_clipRect)) {
        self.tk_clipRect = clipRect;
    }
}

- (void)tk_resetIsVisible {
    //  计算isVisible
    BOOL isVisible = !self.tk_isAlpha0
    && !self.tk_isHidden
    && !CGRectIsEmpty(self.tk_visibleRect);
    self.tk_isVisible = isVisible;
    
    //  计算validVisible
    CGFloat viewVisibleNeedArea = self.frame.size.width * self.frame.size.height * [TKExposeTracking shared].exposeValidSizePercentage;
    CGFloat viewShowArea = self.tk_visibleRect.size.width * self.tk_visibleRect.size.height;
    BOOL isValidVisible = isVisible && (viewShowArea > viewVisibleNeedArea);
    if (self.tk_isValidVisible != isValidVisible) {
        self.tk_isValidVisible = isValidVisible;
        if(isValidVisible){
            if(self.tk_exposeContext){
                [[TKExposeTracking shared] addNeedExposeView:self];
            }
        }
    }
}

- (void)tk_resetIsExposeActive{
    BOOL isActive = self.tk_exposeContext || self.tk_exposeSubviews.count > 0;
    if(self.tk_isExposeActive != isActive){
        self.tk_isExposeActive = isActive;
        if(self.superview){
            if(isActive){
                [self.superview tk_addExposeSubview:self];
            }
            else{
                [self.superview tk_removeExposeSubview:self];
            }
        }
        if(isActive){
            [self tk_resetExposeProperties];
            [self tk_setupExposeKVO];
        }
        else{
            [self tk_clearExposeKVO];
        }
    }
}

- (void)tk_addExposeSubview:(UIView*)view{
    if (view) {
        @synchronized (self.tk_exposeSubviews) {
            if (![self.tk_exposeSubviews containsObject:view]) {
                [self.tk_exposeSubviews addObject:view];
            }
        }
        [self tk_resetIsExposeActive];
    }
}

- (void)tk_removeExposeSubview:(UIView*)view{
    if (view) {
        @synchronized (self.tk_exposeSubviews) {
            [self.tk_exposeSubviews removeObject:view];
        }
        [self tk_resetIsExposeActive];
    }
}

#pragma mark - getter && setter

- (BOOL)tk_isExposeActive {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = @(false);
    }
    return [value boolValue];
}

- (void)setTk_isExposeActive:(BOOL)tk_isExposeActive {
    objc_setAssociatedObject(self, @selector(tk_isExposeActive), @(tk_isExposeActive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHashTable<UIView *> *)tk_exposeSubviews{
    NSHashTable<UIView *> *views = objc_getAssociatedObject(self, _cmd);
    if(!views){
        views = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, @selector(tk_exposeSubviews), views, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return views;
}

- (BOOL)tk_isHidden {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = @(false);
    }
    return [value boolValue];
}

- (void)setTk_isHidden:(BOOL)tk_isHidden {
    objc_setAssociatedObject(self, @selector(tk_isHidden), @(tk_isHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    @synchronized (self.tk_exposeSubviews) {
        for(UIView *view in self.tk_exposeSubviews){
            [view tk_superViewHiddenDidChanged];
        }
    }
}

- (BOOL)tk_isAlpha0 {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = @(false);
    }
    return [value boolValue];
}

- (void)setTk_isAlpha0:(BOOL)tk_isAlpha0 {
    objc_setAssociatedObject(self, @selector(tk_isAlpha0), @(tk_isAlpha0), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    @synchronized (self.tk_exposeSubviews) {
        for(UIView *view in self.tk_exposeSubviews){
            [view tk_superViewAlphaDidChanged];
        }
    }
}

- (NSInteger)tk_layoutTrigger {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setTk_layoutTrigger:(NSInteger)tk_layoutTrigger {
    objc_setAssociatedObject(self, @selector(tk_layoutTrigger), @(tk_layoutTrigger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    @synchronized (self.tk_exposeSubviews) {
        for(UIView *view in self.tk_exposeSubviews){
            [view tk_superViewLayoutTriggerDidChanged];
        }
    }
}

- (CGRect)tk_visibleRect {
    NSValue *value = (NSValue *)objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = @(CGRectZero);
    }
    return [value CGRectValue];
}

- (void)setTk_visibleRect:(CGRect)tk_visibleRect {
    objc_setAssociatedObject(self, @selector(tk_visibleRect), @(tk_visibleRect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)tk_clipRect {
    NSValue *tk_clipRect = (NSValue *)objc_getAssociatedObject(self, _cmd);
    if (!tk_clipRect) {
        tk_clipRect = [NSValue valueWithCGRect:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
    }
    return [tk_clipRect CGRectValue];
}

- (void)setTk_clipRect:(CGRect)tk_clipRect {
    objc_setAssociatedObject(self, @selector(tk_clipRect), @(tk_clipRect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    @synchronized (self.tk_exposeSubviews) {
        for(UIView *view in self.tk_exposeSubviews){
            [view tk_superViewClipRectDidChanged];
        }
    }
}

- (TKExposeContext *)tk_exposeContext {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTk_exposeContext:(TKExposeContext *)tk_exposeContext {
    objc_setAssociatedObject(self, @selector(tk_exposeContext), tk_exposeContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!TKExposeTracking.shared.isEnabled) return;
    [self tk_resetIsExposeActive];
    if (self.tk_isExposeActive){
        // ignore后再决定是否add，相当于刷新一下
        [[TKExposeTracking shared] ignoreView:self];
        if(self.tk_isValidVisible){
            [[TKExposeTracking shared] addNeedExposeView:self];
        }
    }
}

- (void)tk_setExposeContextWithTrackingId:(NSString*_Nullable)trackingId
                                 userData:(id _Nullable)userData {
    TKExposeContext *expose = [TKExposeContext new];
    expose.trackingId = trackingId;
    expose.userData = userData;
    self.tk_exposeContext = expose;
}

- (void)tk_clearExposeContext{
    self.tk_exposeContext = nil;
}

- (BOOL)tk_isValidVisible {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = @(false);
    }
    return [value boolValue];
}

- (void)setTk_isValidVisible:(BOOL)tk_isValidVisible {
    objc_setAssociatedObject(self, @selector(tk_isValidVisible), @(tk_isValidVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tk_isVisible {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        value = @(false);
    }
    return [value boolValue];
}

- (void)setTk_isVisible:(BOOL)tk_isVisible {
    objc_setAssociatedObject(self, @selector(tk_isVisible), @(tk_isVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FBKVOController *)tk_kvo {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTk_kvo:(FBKVOController *)tk_kvo {
    objc_setAssociatedObject(self, @selector(tk_kvo), tk_kvo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
