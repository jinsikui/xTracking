

#import "TKExposeTracking.h"
#import "UIView+TKExposeTracking.h"


@interface TKExposeTracking()

@property (nonatomic, strong) NSMapTable<id, TKExposeEventHandler> *callbackTable;

@property (nonatomic, strong) CADisplayLink *dispalyLink;

@property (nonatomic, assign, readwrite) BOOL isEnabled;
/*
 由于使用者可能在两个刷新间隔间频繁设置如hidden这种参数，导致多计算曝光次数
 所以添加currentNeedExposeViews和lastExposeViews，
 防止在一个屏幕刷新间隔内多次打点
 */
/// 上一帧已经在曝光的views
@property (nonatomic, strong) NSHashTable<UIView *> *lastExposeViews;
/// 下一帧需要曝光打点的views
@property (nonatomic, strong) NSHashTable<UIView *> *currentNeedExposeViews;
/// 临时存储一些数据
@property (nonatomic, strong) NSHashTable<UIView *> *_tmpPool;

@property (nonatomic, assign) BOOL isInBackground;

@end

@implementation TKExposeTracking

+(instancetype)shared{
    static TKExposeTracking *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TKExposeTracking alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _callbackTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
        _lastExposeViews = [NSHashTable weakObjectsHashTable];
        _currentNeedExposeViews = [NSHashTable weakObjectsHashTable];
        __tmpPool = [NSHashTable new];
        _exposeValidSizePercentage = .5;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)appWillEnterForeground:(NSNotification*)notification{
    self.isInBackground = false;
    // 将lastExposeViews合至currentNeedExposeViews，lastExposeViews清空
    @synchronized (self) {
        for (UIView *view in self.lastExposeViews) {
            if (!view.tk_isValidVisible) {
                [self._tmpPool addObject:view];
            }
        }
        [self.lastExposeViews minusHashTable:self._tmpPool];
        [self.currentNeedExposeViews unionHashTable:self.lastExposeViews];
        [self.lastExposeViews removeAllObjects];
        [self._tmpPool removeAllObjects];
    }
}

- (void)appDidEnterBackground:(NSNotification*)notification {
    self.isInBackground = true;
}

- (void)registExposeEventLifeIndicator:(id)lifeIndicator handler:(TKExposeEventHandler)handler {
    [_callbackTable setObject:handler forKey:lifeIndicator];
}

- (void)startExposeTracking {
    self.isEnabled = true;
    if(!_dispalyLink){
        _dispalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(fireDisplayLink)];
        [_dispalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _dispalyLink.paused = false;
    }
}

- (void)stopExposeTracking {
    self.isEnabled = false;
    if(_dispalyLink){
        _dispalyLink.paused = true;
        [_dispalyLink invalidate];
        _dispalyLink = nil;
    }
}

- (void)addNeedExposeView:(UIView *)view {
    @synchronized (self) {
        if (view && ![self.currentNeedExposeViews containsObject:view]) {
            [self.currentNeedExposeViews addObject:view];
        }
    }
}

- (void)ignoreView:(UIView *)view {
    @synchronized (self) {
        [self.currentNeedExposeViews removeObject:view];
        [self.lastExposeViews removeObject:view];
    }
}

- (void)fireDisplayLink {
    @synchronized (self) {
        // 检测上次打点的view是否还在继续显示，如果已经不显示了，从lastExposeViews数组中移除
        for (UIView *view in self.lastExposeViews) {
            if (!view.tk_isValidVisible) {
                [self._tmpPool addObject:view];
            } else {
                //  此view刚刚显示，不需要再打了
                [self.currentNeedExposeViews removeObject:view];
            }
        }
        
        [self.lastExposeViews minusHashTable:self._tmpPool];
        [self.currentNeedExposeViews minusHashTable:self._tmpPool];
        [self._tmpPool removeAllObjects];
        
        for (UIView *view in self.currentNeedExposeViews) {
            if (view.tk_isValidVisible) {
                if(view.tk_exposeContext){
                    TKExposeContext *expose = view.tk_exposeContext;
                    [self sendExposeView:view exposeContext:expose isInBackground:self.isInBackground];
                }
            } else {
                [self._tmpPool addObject:view];
            }
        }
        
        [self.currentNeedExposeViews minusHashTable:self._tmpPool];
        //  把当前显示的所有view集合，合并到一个数组中
        [self.currentNeedExposeViews unionHashTable:self.lastExposeViews];
        [self.lastExposeViews removeAllObjects];
        
        //  switch current & last
        NSHashTable *tmp = self.lastExposeViews;
        self.lastExposeViews = self.currentNeedExposeViews;
        self.currentNeedExposeViews = tmp;
        [self._tmpPool removeAllObjects];
    }
}

- (void)sendExposeView:(UIView *)view
         exposeContext:(TKExposeContext*)exposeContext
        isInBackground:(BOOL)isInBackground {
    NSEnumerator *keyEnum = _callbackTable.keyEnumerator;
    id lifeIndicator;
    while (lifeIndicator = [keyEnum nextObject]) {
        TKExposeEventHandler handler = [_callbackTable objectForKey:lifeIndicator];
        if(handler){
            handler(view, exposeContext, isInBackground);
        }
    }
}

@end
