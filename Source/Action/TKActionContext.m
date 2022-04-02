

#import <Foundation/Foundation.h>
#import "TKActionContext.h"

@implementation TKActionContext

-(instancetype)initWithTrackingId:(NSString*_Nullable)trackingId
                         userData:(id _Nullable)userData{
    self = [super init];
    if(self){
        self.trackingId = trackingId;
        self.userData = userData;
    }
    return self;
}

@end
