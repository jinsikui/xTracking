

#import "AppDelegate.h"
#import "MainViewController.h"
#import "xTacking.h"
#import "TestHeaders.h"


@interface AppDelegate ()
@end

@implementation AppDelegate


void uncaughtExceptionHandler(NSException *exception) {
    [TestLogger.shared log:[NSString stringWithFormat:@"%@\n%@\n", exception, [exception callStackSymbols]]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //崩溃日志
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    [TKPageTracking.shared registPageEventLifeIndicator:self handler:^(TKPageEvent event, TKPageContext * _Nonnull page) {
        NSString *logContent = [NSString stringWithFormat:@"**** 页面打点 %@", page.pageId];
        NSLog(@"%@", logContent);
    }];
    
    [TKExposeTracking.shared registExposeEventLifeIndicator:self handler:^(UIView * _Nonnull view, TKExposeContext * _Nonnull expose, BOOL isInBackground) {
        NSString *logContent = [NSString stringWithFormat:@"**** 曝光打点 %@", expose];
        NSLog(@"%@", logContent);
        [TestLogger.shared log:logContent];
    }];
    [TKActionTracking.shared registActionEventLifeIndicator:self handler:^(id  _Nonnull sender, TKActionContext * _Nonnull action) {
        NSString *logContent = [NSString stringWithFormat:@"**** action打点 %@", action];
        NSLog(@"%@", logContent);
        [[TestLogger shared] log:logContent];
    }];
    TKExposeTracking.shared.exposeValidSizePercentage = 0.1;  //有效曝光面积百分比
    [[TKExposeTracking shared] startExposeTracking];  //启动曝光跟踪
    
    return YES;
}


@end
