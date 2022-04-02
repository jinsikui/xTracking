
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TKExposeContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKExposeContext (TestCode)

- (instancetype)initWithView:(UIView*)view;

- (instancetype)initWithView:(UIView*)view
                         pos:(NSInteger)pos;

@end

NS_ASSUME_NONNULL_END
