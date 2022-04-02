

#import "TestHideAlphaController.h"
#import "TestHeaders.h"
#import "TestLabelView.h"


@interface TestHideAlphaController ()
@property(nonatomic,strong) TestLabelView *testView;
@end

@implementation TestHideAlphaController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = xColor.whiteColor;
    
    _testView = [TestLabelView testView];
    _testView.backgroundColor = UIColor.redColor;
    _testView.textLabel.text = @">:(";
    _testView.frame = CGRectMake(100, 100, 150, 80);
    _testView.textLabel.tk_exposeContext = [TKExposeContext new];
    _testView.textLabel.tk_exposeContext.trackingId = @"testLabel";
    [self.view addSubview:_testView];
    
    [xTask asyncMainAfter:3 task:^{
        //曝光消失
        self.testView.hidden = true;
        [xTask asyncMainAfter:3 task:^{
            //曝光打点
            self.testView.hidden = false;
            [xTask asyncMainAfter:3 task:^{
                //曝光消失
                self.testView.textLabel.alpha = 0;
                [xTask asyncMainAfter:3 task:^{
                    //曝光打点
                    self.testView.textLabel.alpha = 1;
                    [xTask asyncMainAfter:3 task:^{
                        //曝光消失
                        self.testView.alpha = 0;
                        [xTask asyncMainAfter:3 task:^{
                            //曝光打点
                            self.testView.alpha = 1;
                        }];
                    }];
                }];
            }];
        }];
    }];
}

@end
