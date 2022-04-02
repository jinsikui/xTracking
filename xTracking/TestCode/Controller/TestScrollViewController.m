

#import "TestScrollViewController.h"
#import "TestHeaders.h"
#import "TestLabelView.h"

@interface TestScrollViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TestScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    [self setupUI];
}

- (void)setupUI {
    NSArray<NSNumber *> *data = [TestHelper generateDatasWithCount:50];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bounces = NO;
    __block CGFloat bottom = 0;
    CGFloat H = 100;
    [data enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TestLabelView *testV = [TestLabelView testView];
        testV.frame = CGRectMake(100, bottom, 200, H);
        testV.textLabel.text = [NSString stringWithFormat:@"%ld", idx];
        testV.textLabel.tk_exposeContext = [[TKExposeContext alloc] initWithView:testV.textLabel pos:idx];
        testV.tk_exposeContext = [[TKExposeContext alloc] initWithView:testV pos:idx];
        [self.scrollView addSubview:testV];
        bottom += H;
    }];
    self.scrollView.contentSize = CGSizeMake(0, bottom);
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(500);
    }];
}

@end
