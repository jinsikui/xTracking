

#import "TestControlsController.h"
#import "TestHeaders.h"

@interface TestControlsController ()

@end

@implementation TestControlsController

#pragma mark - life circle

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = xColor.whiteColor;
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *btn = [xViewFactory buttonWithTitle:@"按钮" font:kFontRegularPF(13) titleColor:UIColor.systemBlueColor bgColor:UIColor.clearColor borderColor:UIColor.systemBlueColor borderWidth:0.5];
    btn.tk_exposeContext = [[TKExposeContext alloc] initWithView:btn pos:0];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(60);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    UITextField *tf = [[UITextField alloc] init];
    tf.placeholder = @"请输入或扫一扫充值码";
    tf.layer.borderColor = xColor.systemBlueColor.CGColor;
    tf.layer.borderWidth = 0.5;
    tf.font = kFontRegularPF(13);
    tf.tk_exposeContext = [[TKExposeContext alloc] initWithView:tf pos:1];
    [self.view addSubview:tf];
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.equalTo(btn.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(140, 30));
    }];
    
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = true;
    sw.tintColor = [xColor clearColor];
    sw.onTintColor = kColor(0xFF3B97);
    sw.enabled = true;
    sw.tk_exposeContext = [[TKExposeContext alloc] initWithView:sw pos:2];
    [self.view addSubview:sw];
    [sw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.equalTo(tf.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(30, 15));
    }];
    
}



@end
