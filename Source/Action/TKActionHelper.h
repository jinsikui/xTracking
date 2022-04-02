

#import <UIKit/UIKit.h>

#import "ITKActionObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKActionHelper : NSObject

+ (void)reportActionObjectIfNeed:(id)object;

+ (void)setActionContextToObject:(id)object
                      trackingId:(NSString*_Nullable)trackingId
                        userData:(id _Nullable)userData;

+ (void)clearActionContextForObject:(id)object;

@end

NS_ASSUME_NONNULL_END
