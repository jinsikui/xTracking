

#import <UIKit/UIKit.h>
#import "TestLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestLabelView : UIView

@property (nonatomic, strong) TestLabel *textLabel;

+ (instancetype)testView;

@end

NS_ASSUME_NONNULL_END
