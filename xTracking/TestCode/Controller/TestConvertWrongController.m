

#import "TestConvertWrongController.h"
#import "TestHeaders.h"
#import "TestLabelView.h"

@interface TestConvertWrongController ()
@property (nonatomic, strong) xTableView *tableView;
@end

@implementation TestConvertWrongController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView = [[xTableView alloc] initWithTableViewCell];
    self.tableView.rowHeight = 100;
    __weak typeof(self) weak = self;
    self.tableView.buildCellCallback = ^(UITableViewCell * _Nonnull cell, xTableViewCellContext * _Nonnull context) {
        xCollectionView *grid = [cell viewWithTag:1024];
        if(!grid){
            grid = [[xCollectionView alloc] initWithCollectionViewCell];
            grid.tag = 1024;
            grid.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            grid.isScrollEnabled = true;
            grid.itemSize = CGSizeMake(kScreenWidth/3.f, 100);
            grid.buildCellCallback = ^(UICollectionViewCell * _Nonnull subCell, xCollectionViewCellContext * _Nonnull context) {
                subCell.tk_actionContext = [TKActionContext new];
                subCell.tk_actionContext.trackingId = [NSString stringWithFormat:@"collectionCell(%ld)", (long)context.indexPath.item];
                TestLabelView *exposeView = [subCell viewWithTag:2048];
                if(!exposeView){
                    exposeView = [TestLabelView new];
                    exposeView.tag = 2048;
                    exposeView.backgroundColor = xColor.redColor;
                    [subCell.contentView addSubview:exposeView];
                    [exposeView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(0);
                        make.centerX.mas_equalTo(subCell);
                        make.width.mas_equalTo(40);
                        make.height.mas_equalTo(20);
                    }];
                }
                exposeView.textLabel.text = [NSString stringWithFormat:@"%ld", (long)context.indexPath.row];
                /**
                 用模拟器iphone8测试时，当横向滚动UICollectionView时，新的曝光数据出不来，
                 原因是页面加载完成时UITableView的visibleRect.origin.y计算错误（应该为64实际128，加上UITableView的clipToBounds为true，导致子view被认为裁减出屏幕外了）
                 触发UITableView计算visibleRect错误的过程是：
                    -> 当前controller.view.frame被系统设置，触发frame的kvo，进而触发子孙view的kvo，最终导致UITableView调用tk_resetVisibleRect
                        ->UITableView在tk_resetVisibleRect中调convertRect:toView:得出的结果不正确（origin.y应该为64实际128）
                 可见并不是任何时候调convertRect:toView:都能得到正确结果，相信在layoutSubview时调是没问题的，但是在setFrame时立刻调可能不行
                 解决方法是在setFrame的kvo中，异步至主线程处理，实测可以解决至少这个case
                 */
                exposeView.tk_exposeContext = [TKExposeContext new];
                exposeView.tk_exposeContext.trackingId = [NSString stringWithFormat:@"testView:%ld", (long)context.indexPath.row];
                exposeView.tk_actionContext = [TKActionContext new];
                exposeView.tk_actionContext.trackingId = [NSString stringWithFormat:@"gestured label(%ld)", (long)context.indexPath.item];
                exposeView.gestureRecognizers = @[[[UITapGestureRecognizer alloc] initWithTarget:weak action:@selector(actionLabelTap:)]];
                subCell.backgroundColor = TestHelper.randomColor;
            };
            grid.selectCellCallback = ^(UICollectionViewCell * _Nonnull cell, xCollectionViewCellContext * _Nonnull context) {
                [weak actionCellTap:cell];
            };
            [cell.contentView addSubview:grid];
            [grid mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
        }
        grid.hidden = context.indexPath.row > 0;
        if(context.indexPath.row == 0){
            grid.dataList = [TestHelper generateDatasWithCount:30];
            [grid reloadData];
        }
        cell.backgroundColor = TestHelper.randomColor;
    };
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(500);
    }];
    self.tableView.dataList = [TestHelper generateDatasWithCount:50];
    [self.tableView reloadData];
    
    [xToast show:@"测试方法：横向滚动collectionView，\n检查log新曝光是否正确出现" duration:5];
}

-(void)actionLabelTap:(id)gesture{
    NSLog(@">>>>> label tap");
}

-(void)actionCellTap:(id)cell{
    NSLog(@">>>>> cell tap");
}

@end
