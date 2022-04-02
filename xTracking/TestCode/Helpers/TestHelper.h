

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestHelper : NSObject

+ (NSArray<NSNumber *> *)generateDatasWithCount:(NSInteger)count;
+ (UIColor *)randomColor;

@end

NS_ASSUME_NONNULL_END
