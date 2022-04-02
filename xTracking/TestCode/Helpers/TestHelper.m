

#import "TestHelper.h"

@implementation TestHelper

+ (NSArray<NSNumber *> *)generateDatasWithCount:(NSInteger)count {
    NSMutableArray<NSNumber *> *tmp = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        [tmp addObject:@(count)];
    }
    return [tmp copy];
}

+ (UIColor *)randomColor {
    NSInteger aRedValue =arc4random() % 128 + 128;
    NSInteger aGreenValue =arc4random() % 128 + 128;
    NSInteger aBlueValue =arc4random() % 128 + 128;
    UIColor *randColor = [UIColor colorWithRed:aRedValue /255.0f green:aGreenValue /255.0f blue:aBlueValue /255.0f alpha:1.0f];
    return randColor;
}

@end
