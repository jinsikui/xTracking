

#import "TestClickCollectionViewCell.h"
#import "TestHeaders.h"

@interface TestClickCollectionViewCell ()

@property(nonatomic, strong) UILabel *indexLabel;

@end

@implementation TestClickCollectionViewCell

- (void)refresh:(NSIndexPath *)indexPath {
    if(!_indexLabel){
        _indexLabel = [UILabel new];
        _indexLabel.font = kFontRegularPF(14);
        _indexLabel.textColor = kColor(0);
        [self.contentView addSubview:_indexLabel];
        [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self).offset(-20);
        }];
    }
    _indexLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    
    self.tk_actionContext = [[TKActionContext alloc] initWithTarget:self pos:indexPath.item];    
    self.contentView.backgroundColor = TestHelper.randomColor;
}

@end
