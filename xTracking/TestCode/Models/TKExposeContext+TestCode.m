

#import "TKExposeContext+TestCode.h"

@implementation TKExposeContext (TestCode)

- (instancetype)initWithView:(UIView*)view {
    if (self = [super init]) {
        self.trackingId = NSStringFromClass([view class]);
    }
    return self;
}

- (instancetype)initWithView:(UIView*)view
                         pos:(NSInteger)pos {
    if (self = [super init]) {
        self.trackingId = [NSString stringWithFormat:@"%@ -> %ld", NSStringFromClass([view class]), pos];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ : %p>", self.trackingId, self];
}

@end
