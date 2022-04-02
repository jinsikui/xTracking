

#import "ClickTestTableViewController.h"
#import "TestClickTableCell.h"
#import "TestHeaders.h"

@interface ClickTestTableViewController ()

@property (nonatomic, strong) xTableView *tableView;

@end

@implementation ClickTestTableViewController

#pragma mark - life circle

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[xTableView alloc] initWithCellClass:[TestClickTableCell class]];
    self.tableView.rowHeight = 100;
    self.tableView.buildCellCallback = ^(UITableViewCell * _Nonnull cell, xTableViewCellContext * _Nonnull context) {
        TestClickTableCell *c = (TestClickTableCell *)cell;
        [c refresh:context.indexPath];
    };
    self.tableView.selectCellCallback = ^(UITableViewCell * _Nonnull cell, xTableViewCellContext * _Nonnull context) {
        NSString *content = [NSString stringWithFormat:@"测试Log：点击了<tableView_cell(index-%ld)>", context.indexPath.row];
        NSLog(@"%@", content);
        [[TestLogger shared] log:content];
    };
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(500);
    }];
    self.tableView.dataList = [TestHelper generateDatasWithCount:50];
    [self.tableView reloadData];
}

#pragma mark - respond func

@end
