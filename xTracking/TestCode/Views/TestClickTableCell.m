

#import "TestClickTableCell.h"
#import "TestHeaders.h"
#import "TestClickCollectionViewCell.h"

@interface TestClickTableCell ()

@property(nonatomic, strong) UILabel *indexLabel;
@property(nonatomic, strong) xCollectionView *gridView;

@end

@implementation TestClickTableCell

- (void)refresh:(NSIndexPath *)indexPath {
    if(!_indexLabel){
        _gridView = [[xCollectionView alloc] initWithCellClass:TestClickCollectionViewCell.class];
        _gridView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _gridView.isScrollEnabled = true;
        _gridView.itemSize = CGSizeMake(kScreenWidth/3.f, 100);
        _gridView.buildCellCallback = ^(UICollectionViewCell * _Nonnull cell, xCollectionViewCellContext * _Nonnull context) {
            [((TestClickCollectionViewCell*)cell) refresh:context.indexPath];
        };
        _gridView.selectCellCallback = ^(UICollectionViewCell * _Nonnull cell, xCollectionViewCellContext * _Nonnull context) {
            NSString *content = [NSString stringWithFormat:@"测试Log：点击了<collectionView_cell(index-%ld)>", (long)context.indexPath.item];
            NSLog(@"%@", content);
            [[TestLogger shared] log:content];
        };
        [self.contentView addSubview:_gridView];
        [_gridView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _indexLabel = [UILabel new];
        _indexLabel.font = kFontMediumPF(16);
        _indexLabel.textColor = kColor(0);
        [self.contentView addSubview:_indexLabel];
        [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
    }
    _indexLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    _gridView.hidden = indexPath.row > 0;
    if(indexPath.row == 0){
        _gridView.dataList = [TestHelper generateDatasWithCount:30];
        [_gridView reloadData];
    }
    
    self.tk_actionContext = [[TKActionContext alloc] initWithTarget:self pos:indexPath.row];
    self.contentView.backgroundColor = TestHelper.randomColor;
}

@end
