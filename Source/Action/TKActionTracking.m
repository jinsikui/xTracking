

#import "TKActionTracking.h"

@interface TKActionTracking()

@property(nonatomic,strong) NSMapTable<id, TKActionEventHandler> *callbackTable;

@end

@implementation TKActionTracking

+(instancetype)shared{
    static TKActionTracking *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TKActionTracking alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _callbackTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
    }
    return self;
}

- (void)registActionEventLifeIndicator:(id)lifeIndicator handler:(TKActionEventHandler)handler {
    [_callbackTable setObject:handler forKey:lifeIndicator];
}

- (void)sendActionForSender:(id)sender context:(TKActionContext*)action {
    NSEnumerator *keyEnum = _callbackTable.keyEnumerator;
    id lifeIndicator;
    while (lifeIndicator = [keyEnum nextObject]) {
        TKActionEventHandler handler = [_callbackTable objectForKey:lifeIndicator];
        if(handler){
            handler(sender, action);
        }
    }
}

@end
