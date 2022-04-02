

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TKPageContext.h"
#import "TKControllerPageAgent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController(TKPageTracking)
/// 当controller对应唯一的page时，设置这个属性即可添加对page entry/exit的跟踪
@property(nonatomic,strong) TKPageContext *_Nullable tk_page;
/// 用于管理controller和page的关系，当controller可能对应多个page时，
/// 用户需要修改tk_pageAgent.mode，并显示的调用tk_pageAgent.push/pop方法通知页面的进出
@property(nonatomic,strong,readonly) TKControllerPageAgent *_Nonnull tk_pageAgent;
@property(nonatomic,strong) UIViewController *_Nullable tk_modalParentController;
@end

NS_ASSUME_NONNULL_END
