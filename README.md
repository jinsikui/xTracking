# <a name="top"></a>xTracking

* [概述](#概述)
* [安装](#安装)
* [Demo](#demo)
* [页面进出跟踪](#page)
  * [注册事件回调](#pageregist)
  * [声明controller对应的页面](#pagecontroller)
  * [一个controller对应多页面](#pageagent)
* [UI曝光跟踪](#expose)
  * [注册事件回调和启动跟踪](#exposeregist)
  * [给UIView添加曝光跟踪](#exposedeclare)
* [Action跟踪](#action)
  * [注册事件回调](#actionregist)
  * [给控件添加Action跟踪](#actiondeclare)

## 概述

iOS app 自动跟踪软件，包含页面进出跟踪，UI曝光跟踪，用户Action跟踪三个子模块

## 安装

通过pod引用，在podfile增加下面一行，通过tag指定版本，可以按需要单独引入子模块
```
# 引入所有模块
pod 'xTracking',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'vX.X.X-X'

# 单独引入页面跟踪模块
pod 'xTracking/Page',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'vX.X.X-X'
# 单独引入UI曝光跟踪模块
pod 'xTracking/Expose',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'vX.X.X-X'
# 单独引入Action跟踪模块
pod 'xTracking/Action',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'vX.X.X-X'
```
 objc代码中引入：
```
// 引入所有子模块头文件：
#import <xTracking/xTracking.h>

// 或者
#import <xTracking/xTrackingPage.h> // 单独引入页面跟踪子模块头文件
#import <xTracking/xTrackingExpose.h> // 单独引入UI曝光跟踪子模块头文件
#import <xTracking/xTrackingAction.h> // 单独引入Action跟踪子模块头文件
```
 swift代码中引入：
```
在项目的plist文件中配置置 'Objective-C Bridging Header = xxx.h'，在xxx.h中添加一行：
#import <xTracking/xTracking.h>

// 或者按需要添加子模块头文件：
#import <xTracking/xTrackingPage.h>
#import <xTracking/xTrackingExpose.h>
#import <xTracking/xTrackingAction.h>

```

## Demo

下载本工程直接运行即可查看demo

<img src="/Readme/demo.png" alt="drawing" width="350"/>


### <a name="page"></a>页面进出跟踪
[回顶](#top)

#### <a name="pageregist"></a> - 注册事件回调
```objc
// in AppDelegate.m
[TKPageTracking.shared registPageEventLifeIndicator:self handler:^(TKPageEvent event, TKPageContext * _Nonnull page) {
    // event would be TKPageEventEntry or TKPageEventExit
    NSString *pageId = page.pageId; //用户声明的pageId
    id userData = page.userData; //用户声明的业务数据
    // do business logic ...
}];
```
#### <a name="pagecontroller"></a> - 声明controller对应的页面
```objc
// in controller
// 在viewWillAppear之前调用
self.tk_page = [[TKPageContext alloc] initWithPageId:@"xxx" userData:nil];

// 也可以这样声明controller和page的一一对应关系：
[TKPageTracking.shared registPageContext:[[TKPageContext alloc] initWithPageId:@"udeskPageId" userData:nil] forControllerClassName:@"UdeskBaseNavigationViewController"];
```
#### <a name="pageagent"></a> - 一个controller对应多页面
```objc
/***
每一个controller都会通过runtime注入一个pageAgent（TKControllerPageAgent）用于管理controller和日志抽象page（TKPageContext）的关系，在恰当的时候发送page的entry/exit事件

controller和page有一对一和一对多的关系，默认情况下一个controller对应一个page（controller.tk_pageAgent.mode = TKControllerPageModeBindToController）
但有时候一个controller中会有多个page，比如FlutterViewController，H5ViewController，或者在同一个controller中滑动切换view每个view对应一个page
一对多时一个controller对应多个page，这时又有两种情况
1. push/pop模式（controller.tk_pageAgent.mode = TKControllerPageModePushPop）
   比如FlutterViewController，内部子页面对应page，子页面push/pop时通过bridge通知上层，业务代码应该在bridge代码中调用pageAgent.push(page)或pageAgent.pop()，以此通知xTracking有新页面进入或者离开
2. override模式（controller.tk_pageAgent.mode = TKControllerPageModeOverride）
   比如H5ViewController，当一个新的url加载时意味着覆盖旧的page，此时业务代码应该调用pageAgent.push(page)方法，不需要调用pageAgent.pop()
补充一点，无论哪种情况，当controller收到系统的appear/disapper事件时xTracking都会自动对当前page发送entry/exit事件
**/

// in  H5ViewController.viewDidLoad()
self.tk_pageAgent.mode = TKControllerPageModeOverride;

// 当新的url加载后调用：
[self.tk_pageAgent push:[[TKPageContext alloc] initWithPageId:"h5page" userData:url];

```
### <a name="expose"></a>UI曝光跟踪
[回顶](#top)
```
“曝光(expose)”指的是某个UI界面从不可见变为可见，跟踪的某个UI界面每次从不可见变为可见触发一次曝光事件
xTracking支持跟踪任何UIView子类的曝光，只要通过设置UIView.tk_exposeContext 属性声明要求跟踪即可。具体的说，支持以下features：

支持设置frame布局或者autolayout布局
支持UITableViewCell / UICollectionViewCell等可重用组件的曝光跟踪
支持UIScrollView滑动导致的曝光事件
支持页面跳转/跳回导致的UI曝光事件
支持UIView animation导致的UI曝光事件
支持设置最小曝光比例（即view在window中显示的区域超过自身面积比例多少才算作一次曝光）
支持view以及superview的alpha，hidden，clipToBounds属性改变导致的曝光事件
......
不支持兄弟view的遮挡导致的曝光改变
```

#### <a name="exposeregist"></a> - 注册事件回调和启动跟踪
```objc
// in AppDelegate

// 注册事件回调
[TKExposeTracking.shared registExposeEventLifeIndicator:self handler:^(UIView * _Nonnull view, TKExposeContext * _Nonnull expose, BOOL isInBackground) {
    // 用户声明要跟踪的view曝光时触发
    NSString *trackingId = expose.trackingId; //用户声明的trackingId
    id userData = expose.userData; //用户声明的业务数据
    // do business logic ...
}];

// 设置全局的曝光参数
TKExposeTracking.shared.exposeValidSizePercentage = 0.1;  //有效曝光面积百分比，即view在window中显示的区域超过自身面积比例多少才算作一次曝光

// 启动曝光跟踪
[[TKExposeTracking shared] startExposeTracking];  //启动曝光跟踪
```
#### <a name="exposedeclare"></a> - 给UIView添加曝光跟踪
```objc
// 只要设置UIView.tk_exposeContext即可
view.tk_exposeContext = [[TKExpose alloc] initWithTrackingId:@"xxx" userData:nil];

// 可重用cell例子
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"customCellId" forIndexPath:indexPath];
    // ......
    cell.tk_exposeContext = [[TKExpose alloc] initWithTrackingId:[NSString stringWithFormat:@"tracking-%ld", indexPath.row] userData:nil];
    return cell;
}
```
### <a name="action"></a>Action跟踪
[回顶](#top)
```
"Action"指用户触发的UI控件的事件，xTracking支持大部分UIControl控件的action跟踪
特别的支持UIBarButtonItem、UIGestureRecognizer触发的action
```

#### <a name="actionregist"></a> - 注册事件回调
```objc
// in AppDelegate.m
[TKActionTracking.shared registActionEventLifeIndicator:self handler:^(id  _Nonnull sender, TKActionContext * _Nonnull action) {
    NSString *trackingId = action.trackingId; //用户声明的trackingId
    id userData = action.userData; //用户声明的业务数据
    // do business logic ...
}];
```
#### <a name="actiondeclare"></a> - 给控件添加Action跟踪
```objc

// UIButton
UIButton *btn = ...
btn.tk_actionContext = [[TKActionContext alloc] initWithTrackingId:@"xxx" userData:nil];

// 如果需要在点击发生时才生成action数据，也可以使用tk_actionProvider:
btn.tk_actionContextProvider = ^TKActionContext * _Nullable(id<ITKActionObject>  _Nonnull actionObject) {
    return [[TKActionContext alloc] initWithTrackingId:@"xxx" userData:nil];
};

// gesture recognizer
UIView *view = [UIView new];
UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
view.gestureRecognizers = @[ges];
view.tk_actionContext = [[TKActionContext alloc] initWithTrackingId:@"xxx" userData:nil];

// UIBarButtonItem
UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"right" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionTapRightItem)];
self.navigationItem.rightBarButtonItem = rightItem;
rightItem.tk_actionContext = [[TKActionContext alloc] initWithTrackingId:@"xxx" userData:nil];

// ......
```

