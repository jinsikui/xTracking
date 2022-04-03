

#import "MainViewController.h"
#import "TestHeaders.h"
#import "TestTableController.h"
#import "TestScrollViewController.h"
#import "TestLabelView.h"
#import "TestGoPageController.h"
#import "TestConvertWrongController.h"
#import "TestHideAlphaController.h"
#import "TestClipBoundsController.h"
#import "TestView.h"
#import "TestPercentageController.h"
#import "TestTabController.h"
#import "ClickTestTableViewController.h"
#import "HookIssues.h"
#import "TKActionContext+TestCode.h"
#import "TestControlsController.h"
#import "xTacking.h"


@interface MainViewController ()
@property(nonatomic,strong) xNavigation *nav;
@property(nonatomic,strong) UIScrollView *scroll;
@property(nonatomic,strong) UIViewController *c1;
@property(nonatomic,strong) UIViewController *c2;
@property(nonatomic,strong) UITextView *logView;
@property (nonatomic, assign) CGFloat currentY;

@end

@implementation MainViewController

#pragma mark - life circle
- (instancetype)init {
    if (self = [super init]) {
        self.currentY = 30;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view viewWithTag:1992].tk_actionContextProvider = ^TKActionContext * _Nullable(id<ITKActionObject>  _Nonnull actionObject) {
        TKActionContext *action = [[TKActionContext alloc] init];
        action.trackingId = @"我是由provider提供的actionContext";
        return action;
    };
}

#pragma mark - UI func
- (void)setupUI {
    self.title = @"xTracking Test";
    self.view.backgroundColor = kColor(0xFFFFFF);
    UIBarButtonItem *logItem = [[UIBarButtonItem alloc] initWithTitle:@"log" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionLocalLog)];
    self.navigationItem.rightBarButtonItem = logItem;
    logItem.tk_actionContext = [[TKActionContext alloc] initWithTarget:self.navigationItem.rightBarButtonItem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"clear log" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionClearLog)];
    
    _scroll = [[UIScrollView alloc] init];
    _scroll.alwaysBounceVertical = true;
    [self.view addSubview:_scroll];
    [_scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    //  自动曝光测试
    [self addLabel:@"自动曝光测试"];
    [self addBtn:@"曝光测试：tableView" selector:@selector(actionExposeTableView)];
    [self addBtn:@"曝光测试：scrollView" selector:@selector(actionExposeScrollView)];
    [self addBtn:@"曝光测试：动画 & setframe" selector:@selector(actionExposeAnimationView)];
    [self addBtn:@"曝光测试：下一页" selector:@selector(actionExposeGoPage)];
    [self addBtn:@"曝光测试：hide & alpha" selector:@selector(actionExposeHideAlpha)];
    [self addBtn:@"曝光测试：clipToBounds" selector:@selector(actionExposeClipToBounds)];
    [self addBtn:@"曝光测试：convertRect不准问题" selector:@selector(actionExposeConvertToRectWrong)];
    [self addBtn:@"曝光测试：expose percentage" selector:@selector(actionExposePercentage)];
    [self addBtn:@"曝光测试：TabController" selector:@selector(actionExposeTab)];
    [self addBtn:@"曝光测试：HookIssues" selector:@selector(actionHookIssues)];
    [self addBtn:@"曝光测试：UIControls" selector:@selector(actionExposeControls)];
    
    [self addLabel:@"自动点击测试"];
    UIButton *actionTestBtn = [self addBtn:@"点击测试：button" selector:@selector(actionClickButton)];
    actionTestBtn.tag = 1992;
    actionTestBtn.tk_actionContext = [[TKActionContext alloc] initWithTarget:actionTestBtn];
    UIView *actionTestView = [self addViewWithTitle:@"点击测试：Gesture" gestrueAction:@selector(actionClickGesture)];
    actionTestView.tk_actionContext = [[TKActionContext alloc] initWithTarget:actionTestView];
    [self addBtn:@"点击测试：Alert" selector:@selector(actionClickAlert)];
    [self addBtn:@"点击测试：Sheet" selector:@selector(actionClickSheet)];
    [self addBtn:@"TableView/CollectionView" selector:@selector(actionClickTableAndCollectionView)];
    [self addBtn:@"TabbarItem" selector:@selector(actionExposeTab)];
    UISwitch *swc = [self addSwitchWithSelector:@selector(actionClickSwitch)];
    swc.tk_actionContext = [[TKActionContext alloc] initWithTarget:swc];

    //  自动点击测试
    _scroll.contentSize = CGSizeMake(0, self.currentY);
}

-(UIButton *)addBtn:(NSString*)text selector:(SEL)selector{
    UIButton *btn = [xViewFactory buttonWithTitle:text font:kFontRegularPF(12) titleColor:kColor(0) bgColor:xColor.clearColor borderColor:kColor(0) borderWidth:0.5];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0.5 * (xDevice.screenWidth - 200), self.currentY, 200, 40);
    [self.scroll addSubview:btn];
    self.currentY += 50;
    return btn;
}

- (UIView *)addViewWithTitle:(NSString *)text gestrueAction:(SEL)action {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.5 * (xDevice.screenWidth - 200), self.currentY, 200, 40)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:view.bounds];
    textLabel.text = text;
    textLabel.adjustsFontSizeToFitWidth = YES;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:textLabel];
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 0.5;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    view.gestureRecognizers = @[ges];
    [self.scroll addSubview:view];
    self.currentY += 50;
    return view;
}

- (void)addLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0.5 * (xDevice.screenWidth - 200), self.currentY, 200, 40);
    label.text = text;
    label.textColor = [UIColor blackColor];
    [self.scroll addSubview:label];
    self.currentY += 50;
}

- (UISwitch *)addSwitchWithSelector:(SEL)selector{
    UISwitch *swc = [UISwitch new];
    [swc addTarget:self action:selector forControlEvents:(UIControlEventValueChanged)];
    swc.frame = CGRectMake(0.5 * (xDevice.screenWidth - 200), self.currentY, swc.frame.size.width, swc.frame.size.height);
    [self.scroll addSubview:swc];
    self.currentY += 50;
    return swc;
}

#pragma mark - Expose Actions

-(void)actionExposeControls{
    [self.nav push:[TestControlsController new]];
}

-(void)actionHookIssues{
    AA *aa = [AA new];
    [aa printSun];
}

-(void)actionExposeTab{
    [self.nav push:[TestTabController new]];
}

-(void)actionExposePercentage{
    [self.nav push:[TestPercentageController new]];
}

-(void)actionExposeConvertToRectWrong{
    [self.nav push:[TestConvertWrongController new]];
}

-(void)actionExposeClipToBounds{
    [self.nav push:[TestClipBoundsController new]];
}

-(void)actionExposeHideAlpha{
    [self.nav push:[TestHideAlphaController new]];
}

-(void)actionExposeGoPage{
    [self.nav push:[TestGoPageController new]];
}

-(void)actionExposeTableView{
    [self.nav push:[TestTableController new]];
}

-(void)actionExposeScrollView{
    [self.nav push:[TestScrollViewController new]];
}

- (void)actionExposeAnimationView {
    TestLabelView *view = [TestLabelView testView];
    view.textLabel.text = @":-D";
    view.backgroundColor = UIColor.redColor;
    view.tk_exposeContext = [TKExposeContext new];
    view.tk_exposeContext.trackingId = @"animView";
    view.textLabel.tk_exposeContext = [TKExposeContext new];
    view.textLabel.tk_exposeContext.trackingId = @"animView.label";
    view.frame = CGRectMake(kScreenWidth, 100, 100, 80);
    [self.view addSubview:view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:2 animations:^{
            //应该触发曝光
            view.frame = CGRectMake(0, 100, 100, 80);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:2 animations:^{
                view.frame = CGRectMake(-100, 100, 100, 80);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:2 animations:^{
                    //应该触发曝光
                    view.frame = CGRectMake(60, 150, 100, 80);
                } completion:^(BOOL finished) {
                    [xTask asyncMainAfter:5 task:^{
                        CGRect f = view.frame;
                        f.origin.y = 900;
                        f.size.width = 101;
                        view.frame = f;
                        [xTask asyncMainAfter:5 task:^{
                            //应该触发曝光
                            CGRect f = view.frame;
                            f.origin.y = 150;
                            f.size.width = 100;
                            view.frame = f;
                        }];
                    }];
                }];
            }];
        }];
    });
}

-(void)actionLocalLog{
    if(_logView == nil){
        _logView = [UITextView new];
        _logView.backgroundColor = xColor.whiteColor;
        _logView.layer.borderColor = xColor.blueColor.CGColor;
        _logView.layer.borderWidth = 1;
        _logView.text = [TestLogger.shared readAllLog];
        [self.view addSubview:_logView];
        [_logView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.mas_equalTo(0);
        }];
        self.navigationItem.rightBarButtonItem.title = @"hide";
    }
    else{
        [_logView removeFromSuperview];
        _logView = nil;
        self.navigationItem.rightBarButtonItem.title = @"log";
    }
}

-(void)actionClearLog{
    [_logView removeFromSuperview];
    _logView = nil;
    self.navigationItem.rightBarButtonItem.title = @"log";
    [TestLogger.shared clearLog];
}

#pragma mark - Click Actions
- (void)actionClickNavItem {
    NSLog(@"测试Log：点击了<NavItem>");
    [[TestLogger shared] log:@"测试Log：点击了<NavItem>"];
}
- (void)actionClickButton {
    NSLog(@"测试Log：点击了<Button>");
    [[TestLogger shared] log:@"测试Log：点击了<Button>"];
}
- (void)actionClickGesture {
    NSLog(@"测试Log：点击了<Gesture>");
    [[TestLogger shared] log:@"测试Log：点击了<Gesture>"];
}
- (void)actionClickAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Alert" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"测试Log：点击了<Alert>, Yes");
        [[TestLogger shared] log:@"测试Log：点击了<Alert>, Yes"];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"测试Log：点击了<Alert>, No");
        [[TestLogger shared] log:@"测试Log：点击了<Alert>, No"];
    }];
        
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    yesAction.tk_actionContext = [[TKActionContext alloc] initWithTarget:yesAction];
    noAction.tk_actionContext = [[TKActionContext alloc] initWithTarget:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)actionClickSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Sheet" preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"测试Log：点击了<Sheet>, Yes");
        [[TestLogger shared] log:@"测试Log：点击了<Sheet>, Yes"];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"测试Log：点击了<Sheet>, No");
        [[TestLogger shared] log:@"测试Log：点击了<Sheet>, No"];
    }];
        
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    yesAction.tk_actionContext = [[TKActionContext alloc] initWithTarget:yesAction];
    noAction.tk_actionContext = [[TKActionContext alloc] initWithTarget:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)actionClickTableAndCollectionView {
    [self.nav push:[ClickTestTableViewController new]];
}
- (void)actionClickSwitch {
    NSLog(@"测试Log：点击了<Switch>");
    [[TestLogger shared] log:@"测试Log：点击了<Switch>"];
}

#pragma mark - lazy load
- (xNavigation *)nav {
    if (!_nav) {
        _nav = [xNavigation new];
    }
    return _nav;
}

@end
