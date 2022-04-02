

#import "TestGoPageController.h"
#import "TestHeaders.h"
#import "TestLabelView.h"
#import "TestEmptyController.h"

@interface TestGoPageController ()

@end

@implementation TestGoPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = xColor.whiteColor;
    self.view.tk_exposeContext = [TKExposeContext new];
    self.view.tk_exposeContext.trackingId = @"rootView";
    TestLabelView *view = [TestLabelView testView];
    view.backgroundColor = UIColor.redColor;
    view.frame = CGRectMake(100, 100, 150, 80);
    view.tk_exposeContext = [TKExposeContext new];
    view.tk_exposeContext.trackingId = @"simpleView";
    [self.view addSubview:view];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一页" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionGoPage)];
}

-(void)actionGoPage{
    [self.navigationController pushViewController:[TestEmptyController new] animated:true];
}

@end
