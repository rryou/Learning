//
//  EMPopupViewManager.h
//  EMStock
//
//  Created by Samuel on 15/3/24.
//  Copyright (c) 2015年 flora. All rights reserved.
//



#import <Foundation/Foundation.h>

/**
 *  弹框管理队列, 用来管理EMPopupView及其子类, 以及EMSystemAlertPopupView
 *  EMSystemAlertPopupView继承于UIAlertView比较特殊
 */

NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSPopupViewManager : NSObject

+ (MSPopupViewManager *)sharedManager;

/**
 *  加入队列
 *
 *  @param popupView 弹框
 *
 *  @return 是否成功标志
 */
- (BOOL)enqueuePopupView:(UIView *)popupView;


/**
 *  出队列
 *
 *  @return 是否成功标志
 */
- (BOOL)dequeuePopupView;


/**
 *  出队列, 指定的popupview
 *
 *  @param popupView
 *
 *  @return 是否成功标志
 */
- (BOOL)dequeuePopupView:(UIView *)popupView;


/**
 *  返回当前第一个弹框
 *
 *  @return 返回第一个弹框
 */
- (UIView *)firstPopupView;


/**
 *  是否是空队列
 *
 *  @return 是否是空队列
 */
- (BOOL)isEnqueueEmpty;


/**
 *  该弹框是否在队列之中
 *
 *  @param popupView 弹框
 *
 *  @return 该弹框是否在队列之中
 */
- (BOOL)isInQueue:(UIView *)view;


/**
 *  全部出列
 */
- (void)dequeueAll;

@end
