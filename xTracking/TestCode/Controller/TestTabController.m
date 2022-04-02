

#import "TestTabController.h"
#import "TestHeaders.h"
#import "TestView.h"

@interface TestTabController ()
@property(nonatomic,strong) UINavigationController *c1;
@property(nonatomic,strong) UINavigationController *c2;
@end

@implementation TestTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    _c1 = [self makeControllerTitle:@"消息" normalImageName:@"tab-msg" selectImageName:@"tab-msg-select"];
    UIView *view1 = _c1.topViewController.view;
    TestView *exposeView1 = [TestView new];
    exposeView1.backgroundColor = xColor.redColor;
    exposeView1.tk_exposeContext = [TKExposeContext new];
    exposeView1.tk_exposeContext.trackingId = @"testView1";
    exposeView1.frame = CGRectMake(100, 100, 150, 100);
    [view1 addSubview:exposeView1];
    
    _c2 = [self makeControllerTitle:@"我的" normalImageName:@"tab-user" selectImageName:@"tab-user-select"];
    UIView *view2 = _c2.topViewController.view;
    TestView *exposeView2 = [TestView new];
    exposeView2.backgroundColor = xColor.redColor;
    exposeView2.tk_exposeContext = [TKExposeContext new];
    exposeView2.tk_exposeContext.trackingId = @"testView2";
    exposeView2.frame = CGRectMake(50, 200, 150, 100);
    [view2 addSubview:exposeView2];
    
    self.viewControllers = @[_c1, _c2];
    UITabBar.appearance.barTintColor = xColor.whiteColor;
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName: kColor(0x88889C)} forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName: kColor(0x22262F)} forState:UIControlStateSelected];
    
}

- (UINavigationController*)makeControllerTitle:(NSString*)title
            normalImageName:(NSString*)normalImageName
            selectImageName:(NSString*)selectImageName{
    UIViewController *c = [UIViewController new];
    c.view.backgroundColor = UIColor.whiteColor;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:c];
    UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:normalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectImageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav.tabBarItem = tab;
    tab.tk_actionContext = [[TKActionContext alloc] initWithTarget:title];
    return nav;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
