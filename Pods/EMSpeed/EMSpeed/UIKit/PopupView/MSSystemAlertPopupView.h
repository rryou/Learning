//
//  EMAlertPopupView.h
//  EMStock
//
//  Created by Samuel on 15/3/25.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPopupView.h"


/**
 *  系统弹框, 具有队列管理功能
 */
NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSSystemAlertPopupView : UIAlertView <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL managedByQueue; // 由队列管理, 默认YES, 调用show后不能再设置
@property (nonatomic, assign) BOOL isAutoDismiss; // 是否自动消失
@property (nonatomic, assign) float autoDismissDelaySeconds; // 默认2秒


/**
 *  标题, 没有按钮的, 自动隐藏的
 *
 *  @param title 标题
 *
 *  @return EMSystemAlertPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title;


/**
 *  标题, 内容, 没有按钮的, 自动隐藏的
 *
 *  @param title   标题
 *  @param content 内容
 *
 *  @return EMSystemAlertPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content;


/**
 *  标题, 内容, 中间一个按钮
 *
 *  @param title       标题
 *  @param content     内容
 *  @param buttonTitle 按钮
 *  @param block       按钮block
 *
 *  @return EMSystemAlertPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
        buttonTitle:(NSString *)buttonTitle
              block:( ms_popupview_event_block_t)block;


/**
 *  标题, 内容, 两个按钮
 *
 *  @param title      标题
 *  @param content    内容
 *  @param leftTitle  左按钮标题
 *  @param leftBlock  左按钮block
 *  @param rigthTitle 右按钮标题
 *  @param rightBlock 右按钮block
 *
 *  @return EMSystemAlertPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
          leftBlock:( ms_popupview_event_block_t)leftBlock
   rightButtonTitle:(NSString *)rigthTitle
         rightBlock:( ms_popupview_event_block_t)rightBlock;

@end
