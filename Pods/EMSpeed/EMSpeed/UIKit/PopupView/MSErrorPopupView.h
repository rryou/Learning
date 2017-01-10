//
//  EMErrorView.h
//  EMStock
//
//  Created by Samuel on 15/3/24.
//  Copyright (c) 2015年 flora. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MSPopupView.h"

/**
 *  自定义错误风格的弹框
 */
NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSErrorPopupView : MSPopupView


/**
 *  点击事件block
 */
@property (nonatomic, copy) ms_popupview_event_block_t block;


/**
 *  根据文字弹出弹框
 *
 *  @param text 文字
 *
 *  @return 实例 EMErrorPopupView
 */
+ (instancetype)errorPopupWithText:(NSString *)text;


/**
 *  根据文字弹出弹框
 *
 *  @param text  文字
 *  @param block 点击事件block
 *
 *  @return 实例 EMErrorPopupView
 */
+ (instancetype)errorPopupWithText:(NSString *)text
                             block:(ms_popupview_event_block_t)block;


- (void)show;
- (void)dismiss;

@end
