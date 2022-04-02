

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 代表一个抽象的页面
@interface TKPageContext : NSObject

-(instancetype)init; //for swift unwrap issues

/// 页面的跟踪Id，由用户使用，xTracking并不依赖这个属性
@property(nonatomic,copy)   NSString *_Nonnull pageId;
/// 页面进入时间，不需要用户维护
@property(nonatomic,strong) NSNumber *_Nullable pageEntryTs;
@property(nonatomic,strong) id _Nullable userData;
-(void)updatePageEntryTs;

-(instancetype)initWithPageId:(NSString*_Nullable)pageId
                     userData:(id _Nullable)userData;

@end

NS_ASSUME_NONNULL_END
