

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TKPageContext.h"

NS_ASSUME_NONNULL_BEGIN

/// 本类（TKControllerPageAgent）用于管理controller和日志抽象page（TKPageContext）的关系，在恰当的时候发送page的entry/exit事件
/// 每一个controller都会通过runtime注入一个pageAgent
/// controller和page有一对一和一对多的关系，默认情况下一个controller对应一个page（mode = TKControllerPageModeBindToController）
/// 但有时候一个controller中会有多个page，比如FlutterViewController，H5ViewController，在同一个controller中滑动切换view每个view对应一个page
/// 一对多时一个controller对应多个page，这时又有两种情况
/// 1. push/pop模式（mode = TKControllerPageModePushPop），比如FlutterViewController，内部子页面对应page，push/pop时通过bridge通知上层，这时pageAgent维护一个page的栈，在适当的时候发送page进出事件
/// 2. override模式（mode = TKControllerPageModeOverride），比如H5ViewController，当一个新的page加载时意味着覆盖旧的page，也可以理解为page的栈中永远只有一个
/// 补充一点，无论哪种情况，当controller收到系统的appear/disapper事件时都应该对当前page发送entry/exit事件

typedef enum TKControllerPageMode{
    TKControllerPageModeBindToController = 0,
    TKControllerPageModePushPop = 1,
    TKControllerPageModeOverride = 2
}TKControllerPageMode;

@interface TKControllerPageAgent : NSObject

@property(nonatomic,assign) TKControllerPageMode mode;

@property(nonatomic,strong,readonly) TKPageContext *_Nullable topPage;

/// 仅当mode == bindToController时才起作用
-(void)bindToControllerIfNeed:(UIViewController*)controller;
/// 当mode == pushpop或model == override时用户自己管理controller中页面的进入
-(void)push:(TKPageContext*)pageContext;
/// 当mode == pushpop时用户自己管理controller中页面的退出
-(void)pop;
/// controller收到系统的viewWillAppear事件时自动调用
-(void)appear;
/// controller收到系统的viewWillDisappear事件时自动调用
-(void)disappear;
@end

NS_ASSUME_NONNULL_END
