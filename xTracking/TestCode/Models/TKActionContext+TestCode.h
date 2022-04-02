

#import <Foundation/Foundation.h>
#import "TKActionContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKActionContext (TestCode)


- (instancetype)initWithTarget:(id)target;

- (instancetype)initWithTarget:(id)target
                           pos:(NSInteger)pos;

@end

NS_ASSUME_NONNULL_END
