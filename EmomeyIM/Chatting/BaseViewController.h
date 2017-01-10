//
//  BaseViewController.h
//  LoochaUtilities
//
//  Created by xiuwei ding on 12-9-25.
//  Copyright (c) 2012年 realcloud. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ControllerObserveProtocol.h"
#ifndef __IPHONE_7_0
#endif

@interface NavigationBarStyle : NSObject

@property(nonatomic,assign) BOOL hidden;
@property(nonatomic,assign) UIBarStyle barStyle;
@property(nonatomic,assign) BOOL translucent;
@property(nonatomic,retain) UIColor *tintColor;

@end

@interface BaseViewController : UIViewController
{
    NavigationBarStyle *navigationBarStyle;
    
    CGFloat topOffset;
    BOOL isAppearing;
    BOOL isDateComeFromServerOver;//标示 数据请求是否 已经从服务器 获取结束  用于提示暂无数据等 dxw
}

@property (nonatomic,readonly,retain) NavigationBarStyle *navigationBarStyle;
@property (nonatomic) CGFloat topOffset;
@property (nonatomic, readonly) BOOL isAppearing;

//不重复路径，然后push
- (void)pushViewControllerWithClass:(Class)controllerClass animated:(BOOL)animated smartMode:(BOOL)smartMode;

- (void)addControllerObserver:(id<ControllerObserveProtocol>)observer;

- (void)removeControllerObserver:(id<ControllerObserveProtocol>)observer;

- (void)stateWhenDidAppear;
- (void)stateWhenDidDisAppear;

@end

@interface UIViewController (Loocha)

+ (NSString *)compatibleClassCategory;

// return YES if 两类型的对象被认为是相兼容的，在程序里可以认为是同一类，默认情况是isMemberOfClass
// return YES if 两类型的对象被认为是相兼容的，在程序里可以认为是同一类，默认情况是isMemberOfClass
- (BOOL)compatibleWithClass:(Class)controllerClass;

+ (BOOL)shouldBlurScreen;


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
@end
