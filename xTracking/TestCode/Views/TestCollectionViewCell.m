

#import "TestCollectionViewCell.h"
#import "TestHeaders.h"
#import "TestLabel2.h"

@interface TestCollectionViewCell ()

@property(nonatomic, strong) TestLabel2 *indexLabel;

@end

@implementation TestCollectionViewCell

- (void)dealloc {
    NSLog(@"TestCollectionViewCell dealloc");
}

- (void)refresh:(NSIndexPath *)indexPath {
    if(!_indexLabel){
        _indexLabel = [TestLabel2 new];
        _indexLabel.font = kFontRegularPF(14);
        _indexLabel.textColor = kColor(0);
        [self.contentView addSubview:_indexLabel];
        [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self).offset(-20);
        }];
    }
    _indexLabel.text = [NSString stringWithFormat:@"c-%ld", indexPath.row];
    self.contentView.backgroundColor = TestHelper.randomColor;
    self.tk_exposeContext = [[TKExposeContext alloc] initWithView:self pos:indexPath.row];
    _indexLabel.tk_exposeContext = [[TKExposeContext alloc] initWithView:_indexLabel pos:indexPath.row];
}

@end
