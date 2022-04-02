

#import "TestTableController.h"
#import "TestTableCell.h"
#import "TestEmptyController.h"
#import "TestHeaders.h"

@interface TestTableController ()

@property (nonatomic, strong) xTableView *tableView;

@end

@implementation TestTableController

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
    self.tableView = [[xTableView alloc] initWithCellClass:[TestTableCell class]];
    self.tableView.bounces = false;
    self.tableView.rowHeight = 100;
    self.tableView.buildCellCallback = ^(UITableViewCell * _Nonnull cell, xTableViewCellContext * _Nonnull context) {
        TestTableCell *c = (TestTableCell *)cell;
        [c refresh:context.indexPath];
    };
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(500);
    }];
    self.tableView.dataList = [TestHelper generateDatasWithCount:50];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一页" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionNextPage)];
}

#pragma mark - respond func
- (void)actionNextPage {
    [[xNavigation new] push:[TestEmptyController new]];
}

@end
