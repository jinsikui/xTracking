

#import "TKActionContext+TestCode.h"

@implementation TKActionContext (TestCode)

- (instancetype)initWithTarget:(id)target{
    if (self = [super init]) {
        if ([target isKindOfClass:[NSString class]]) {
            self.trackingId = target;
        } else {
            self.trackingId = NSStringFromClass([target class]);
        }
    }
    return self;
}

- (instancetype)initWithTarget:(id)target
                           pos:(NSInteger)pos {
    if (self = [super init]) {
        if ([target isKindOfClass:[NSString class]]) {
            self.trackingId = target;
        } else {
            self.trackingId = [NSString stringWithFormat:@"%@ -> %ld", NSStringFromClass([target class]), pos];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ : %p>", self.trackingId, self];
}

@end
