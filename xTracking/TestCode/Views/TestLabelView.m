

#import "TestLabelView.h"
#import "TestHeaders.h"
#import "TestLayer.h"
#import "TestLabel.h"

@interface TestLabelView ()

@end

@implementation TestLabelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = TestHelper.randomColor;
        _textLabel = [TestLabel new];
        _textLabel.font = kFontSemiboldPF(14);
        _textLabel.textColor = kColor(0xFFFFFF);
        [self addSubview:_textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
    }
    return self;
}

+ (instancetype)testView{
    return [self new];
}

#pragma mark - override

+ (Class)layerClass {
    return [TestLayer class];
}

@end
