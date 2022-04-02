

#import <UIKit/UIKit.h>
#import "TKExposeContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TKExposeEventHandler)(UIView *view, TKExposeContext *expose, BOOL isInBackground);

@interface TKExposeTracking : NSObject

+(instancetype)shared;

@property (nonatomic, assign, readonly) BOOL isEnabled;
/// 用户设置，view展示多少以上视为曝光，默认0.5 (0~1, 0为展示即曝光, 1为必须全部展示才视为曝光)
@property (nonatomic, assign) CGFloat exposeValidSizePercentage;
/// 用户调用，启动曝光跟踪（全局）
- (void)startExposeTracking;
/// 用户调用，停止曝光跟踪（全局）
- (void)stopExposeTracking;
/// 用户使用，用于注册曝光事件监听，注册的handler的生命周期和lifeIndicator一致
- (void)registExposeEventLifeIndicator:(id)lifeIndicator handler:(TKExposeEventHandler)handler;


- (void)addNeedExposeView:(UIView *)view;
- (void)ignoreView:(UIView *)view;
- (void)sendExposeView:(UIView *)view
         exposeContext:(TKExposeContext*)expose
        isInBackground:(BOOL)isInBackground;
@end

NS_ASSUME_NONNULL_END
