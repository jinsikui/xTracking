

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestLogger : NSObject

+(instancetype)shared;

-(void)log:(NSString*)str;

-(void)clearLog;

-(NSString*)readAllLog;

@end

NS_ASSUME_NONNULL_END
