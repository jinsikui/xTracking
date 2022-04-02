

#import "TKControllerPageAgent.h"
#import "TKPageTracking.h"

@interface TKControllerPageAgent()

@property(nonatomic,strong) NSMutableArray<TKPageContext*> *pageStack;
@property(nonatomic,assign) BOOL hasDisappeared;
@property(nonatomic,weak) UIViewController *bindedController;

@end

@implementation TKControllerPageAgent

-(instancetype)init{
    self = [super init];
    if(self){
        _pageStack = [NSMutableArray new];
    }
    return self;
}

-(void)bindToControllerIfNeed:(UIViewController*)controller{
    if(self.mode != TKControllerPageModeBindToController){
        return;
    }
    if(self.topPage != nil){
        //已经绑定过了
        return;
    }
    TKPageContext *page = [TKPageTracking.shared getPageContextFromController:controller];
    if(page == nil){
        //用户不需要对该controller进行跟踪
        return;
    }
    self.bindedController = controller;
    [_pageStack removeAllObjects];
    [_pageStack addObject:page];
}

-(void)push:(TKPageContext*)pageContext{
    TKPageContext *last = _pageStack.lastObject;
    if(last){
        [self sendExit:last];
        if(self.mode != TKControllerPageModePushPop){
            [_pageStack removeAllObjects];
        }
    }
    [self sendEntry:pageContext];
    [_pageStack addObject:pageContext];
}

-(void)pop{
    TKPageContext *page = self.topPage;
    if(page){
        [self sendExit:page];
        [_pageStack removeObject:page];
    }
    page = self.topPage;
    if(page){
        [self sendEntry:page];
    }
}

-(void)appear{
    if(self.mode != TKControllerPageModeBindToController && !_hasDisappeared){
        //防止第一次appear和push重复发送entry事件
        return;
    }
    TKPageContext *page = self.topPage;
    if(page){
        [self sendEntry:page];
    }
}

-(void)disappear{
    _hasDisappeared = true;
    TKPageContext *page = self.topPage;
    if(page){
        [self sendExit:page];
    }
}

-(TKPageContext*)topPage{
    if(_pageStack.count == 0){
        return nil;
    }
    return _pageStack.lastObject;
}

-(void)sendEntry:(TKPageContext*)page{
    [page updatePageEntryTs];
    [[TKPageTracking shared] sendPageEntry:page];
}

-(void)sendExit:(TKPageContext*)page{
    [[TKPageTracking shared] sendPageExit:page];
}
@end
