


NS_ASSUME_NONNULL_BEGIN

/// 代表需要跟踪用户action(如点击)的控件
@interface TKActionContext : NSObject

/// 控件的跟踪Id，由用户使用，xTracking并不依赖这个属性
@property(nonatomic,copy) NSString *_Nullable trackingId;
@property(nonatomic,strong) id _Nullable userData;

-(instancetype)initWithTrackingId:(NSString*_Nullable)trackingId
                         userData:(id _Nullable)userData;

@end

NS_ASSUME_NONNULL_END
