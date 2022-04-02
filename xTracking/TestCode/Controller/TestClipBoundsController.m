

#import "TestClipBoundsController.h"
#import "TestHeaders.h"
#import "TestLabelView.h"

@interface TestClipBoundsController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) TestLabelView *exposeView;
@end

@implementation TestClipBoundsController

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
    
    _view1 = [UIView new];
    _view1.backgroundColor = xColor.redColor;
    [self.scrollView addSubview:_view1];
    _view1.frame = CGRectMake(0, kScreenHeight - kStatusBarHeight - kNavBarHeight - 100, 150, 100);
    
    _exposeView = [TestLabelView new];
    _exposeView.textLabel.text = @">:(";
    _exposeView.backgroundColor = xColor.blueColor;
    _exposeView.tk_exposeContext = [TKExposeContext new];
    _exposeView.tk_exposeContext.trackingId = @"testView";
    _exposeView.frame = CGRectMake(150, 10, 50, 50);
    [_view1 addSubview:_exposeView];
    
    [xTask asyncMainAfter:3 task:^{
        //执行后曝光消失
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(200);
        }];
        [xTask asyncMainAfter:3 task:^{
            //执行后曝光打点
            self.scrollView.clipsToBounds = false;
            [xTask asyncMainAfter:3 task:^{
                //执行后曝光消失
                self.scrollView.clipsToBounds = true;
                [xTask asyncMainAfter:3 task:^{
                    //执行后曝光打点
                    self.view1.frame = CGRectMake(0, 200 - 100, 150, 100);
                    [xTask asyncMainAfter:3 task:^{
                        //执行后曝光消失
                        self.view1.frame = CGRectMake(kScreenWidth - 150, 200 - 100, 150, 100);
                        [xTask asyncMainAfter:3 task:^{
                            //执行后曝光打点
                            self.view1.frame = CGRectMake(0, 200 - 100, 150, 100);
                            
                        }];
                    }];
                }];
            }];
        }];
    }];
}
@end
