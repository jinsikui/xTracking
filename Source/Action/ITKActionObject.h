

#import <UIKit/UIKit.h>
#import "TKActionContext.h"

NS_ASSUME_NONNULL_BEGIN

/// 代表抽象出来的要跟踪用户action的控件，比如UIButton，UIGestureRecognizer
@protocol ITKActionObject <NSObject>

typedef TKActionContext*_Nullable (^TKActionContextProvider)(id<ITKActionObject> _Nonnull actionObject);

@property (nonatomic, strong) TKActionContext * _Nullable tk_actionContext;

/// action数据的provider，provider优先级高于 "tk_actionContext"。
/// 如果设置了provider， 将以provider为准， tk_actionContext不再生效。
/// 如果你在provider返回空，则不通知该事件
@property (nonatomic, copy) TKActionContextProvider _Nullable tk_actionContextProvider;


/// 方便用户的快捷方法
- (void)tk_setActionContextWithTrackingId:(NSString *_Nullable)trackingId
                                 userData:(id _Nullable)userData;

- (void)tk_clearActionContext;

@end


NS_ASSUME_NONNULL_END
