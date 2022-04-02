//
//  xTrackingUITests.m
//  xTrackingUITests
//
//  Created by JSK on 2022/3/30.
//

#import <XCTest/XCTest.h>

@interface xTrackingUITests : XCTestCase

@end

@implementation xTrackingUITests

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testTable {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    // 清空日志
    XCUIElement *navBar = app.navigationBars[@"xTracking Test"];
    [navBar.buttons[@"clear log"] tap];
    
    // 进入测试页面
    [app.buttons[@"曝光测试：tableView"].staticTexts[@"曝光测试：tableView"] tap];
    
    // tableView滑至最下
    XCUIElement *table = app.tables.firstMatch;
    XCUIElement *t49 = table.staticTexts[@"t-49"];
    while(!t49.exists || !t49.isHittable){
        [table swipeUp];
    }
    [table swipeUp]; //多滑动一次，保证滑到头
    // tableView滑至最上
    XCUIElement *t0 = table.staticTexts[@"t-0"];
    while(!t0.exists || !t0.isHittable){
        [table swipeDown];
    }
    [table swipeDown];
    // collectionView滑至最右边
    XCUIElement *c29 = table.staticTexts[@"c-29"];
    XCUIElement *tcell0 = table.cells.firstMatch;
    while(!c29.exists || !c29.isHittable){
        [tcell0 swipeLeft];
    }
    [tcell0 swipeLeft];
    // collectionView滑至最左边
    XCUIElement *c0 = table.staticTexts[@"c-0"];
    while(!c0.exists || !c0.isHittable){
        [tcell0 swipeRight];
    }
    [tcell0 swipeRight];
    
    // 返回
    [navBar.buttons[@"xTracking Test"] tap];
    // 点击log
    [navBar.buttons[@"log"] tap];
    // 获取log内容
    XCUIElement *textview = [app descendantsMatchingType:XCUIElementTypeTextView].firstMatch;
    NSString *log = textview.value;
    NSLog(@">>>>> %@ <<<<<", log);
    // 比较曝光出现次数
    NSUInteger count;
    count = [self _occurTimesForString:@"TestTableCell ->" inString:log];
    XCTAssertEqual(count, 95); //50 + 45
    count = [self _occurTimesForString:@"TestLabel ->" inString:log];
    XCTAssertEqual(count, 95); //50 + 45
    count = [self _occurTimesForString:@"TestCollectionViewCell ->" inString:log];
    XCTAssertEqual(count, 60); //3 + 3 + 27 + 27
    count = [self _occurTimesForString:@"TestLabel2 ->" inString:log];
    XCTAssertEqual(count, 60); //3 + 3 + 27 + 27
}

-(NSUInteger)_occurTimesForString:(NSString*)str inString:(NSString*)strContent {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:str options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:strContent options:0 range:NSMakeRange(0, [strContent length])];
    return numberOfMatches;
}

@end
