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
pod 'xTracking',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'v1.1.0-0'

# 单独引入页面跟踪模块
pod 'xTracking/Page',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'v1.1.0-0'
# 单独引入UI曝光跟踪模块
pod 'xTracking/Expose',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'v1.1.0-0'
# 单独引入Action跟踪模块
pod 'xTracking/Action',     :git => "https://github.com/jinsikui/xTracking.git", :tag => 'v1.1.0-0'
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

![Alt text](/Readme/demo.jpeg)


### <a name="page"></a>页面进出跟踪


### <a name="expose"></a>UI曝光跟踪


### <a name="action"></a>Action跟踪


