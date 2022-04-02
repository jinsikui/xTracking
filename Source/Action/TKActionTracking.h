

#import <UIKit/UIKit.h>
#import "TKActionContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TKActionEventHandler)(id sender, TKActionContext *action);

@interface TKActionTracking : NSObject

+(instancetype)shared;

/// 用户使用，用于注册action事件监听，注册的handler的生命周期和lifeIndicator一致
- (void)registActionEventLifeIndicator:(id)lifeIndicator handler:(TKActionEventHandler)handler;

- (void)sendActionForSender:(id)sender context:(TKActionContext*)action;

@end

NS_ASSUME_NONNULL_END
