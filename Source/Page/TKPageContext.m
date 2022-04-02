

#import "TKPageContext.h"
#import "UIViewController+TKPageTracking.h"

@implementation TKPageContext

-(instancetype)init{
    return [super init];
}

-(instancetype)initWithPageId:(NSString*_Nullable)pageId
                     userData:(id _Nullable)userData{
    self = [super init];
    if(self){
        self.pageId = pageId;
        self.userData = userData;
    }
    return self;
}

- (void)updatePageEntryTs{
    self.pageEntryTs = @((long long)([[NSDate date] timeIntervalSince1970] * 1000));
}

@end
