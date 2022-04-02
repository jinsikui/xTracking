

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKClassHooker : NSObject

+ (void)exchangeOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass;
+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass;

@end

NS_ASSUME_NONNULL_END
