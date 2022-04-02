

#import "TestPercentageController.h"
#import "TestHeaders.h"
#import "TestView.h"

@interface TestPercentageController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TestView *exposeView;
@end

@implementation TestPercentageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = xColor.whiteColor;
    self.navigationController.navigationBar.translucent = NO;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = TestHelper.randomColor;
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    _exposeView = [TestView new];
    _exposeView.backgroundColor = xColor.redColor;
    _exposeView.tk_exposeContext = [TKExposeContext new];
    _exposeView.tk_exposeContext.trackingId = @"testView";
    [self.scrollView addSubview:_exposeView];
    _exposeView.frame = CGRectMake(0.5 * (kScreenWidth - 150), 80, 150, 100);
    
    self.scrollView.contentSize = CGSizeMake(0, kScreenHeight * 2);
    
    [xToast show:@"测试方法：在AppDelegate中设置\nexposeValidSizePercentage &\nexposeValidTimeInterval\n后测试" duration:5];
}

@end
