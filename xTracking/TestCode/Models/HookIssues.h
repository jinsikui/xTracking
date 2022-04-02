

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A : NSObject

-(void)printSun;

@end

@interface A(Hook)
@end

@interface A(Hook2)
@end

@interface AA : A

-(void)printSun;

@end

@interface AA(Hook)
@end

@interface AA(Hook2)
@end

NS_ASSUME_NONNULL_END
