

#import "TestTableCell.h"
#import "TestHeaders.h"
#import "TestCollectionViewCell.h"
#import "TestLabel.h"

@interface TestTableCell()

@property(nonatomic, strong) TestLabel *indexLabel;
@property(nonatomic, strong) xCollectionView *gridView;

@end

@implementation TestTableCell

- (void)dealloc {
    NSLog(@"TestTableCell dealloc");
}

- (void)refresh:(NSIndexPath *)indexPath {
    if(!_indexLabel){
        _gridView = [[xCollectionView alloc] initWithCellClass:TestCollectionViewCell.class];
        _gridView.bounces = false;
        _gridView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _gridView.isScrollEnabled = true;
        _gridView.itemSize = CGSizeMake(kScreenWidth/3.f, 100);
        _gridView.buildCellCallback = ^(UICollectionViewCell * _Nonnull cell, xCollectionViewCellContext * _Nonnull context) {
            [((TestCollectionViewCell*)cell) refresh:context.indexPath];
        };
        [self.contentView addSubview:_gridView];
        [_gridView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _indexLabel = [TestLabel new];
        _indexLabel.font = kFontMediumPF(16);
        _indexLabel.textColor = kColor(0);
        [self.contentView addSubview:_indexLabel];
        [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
    }
    _indexLabel.text = [NSString stringWithFormat:@"t-%ld", indexPath.row];
    _indexLabel.tk_exposeContext = [[TKExposeContext alloc] initWithView:_indexLabel pos:indexPath.row];
    self.tk_exposeContext = [[TKExposeContext alloc] initWithView:self pos:indexPath.row];
    _gridView.hidden = indexPath.row > 0;
    if(indexPath.row == 0){
        _gridView.dataList = [TestHelper generateDatasWithCount:30];
        [_gridView reloadData];
    }
    self.contentView.backgroundColor = TestHelper.randomColor;
}

@end
