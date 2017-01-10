//
//  EMSocialViewController.h
//  Social
//
//  Created by Sam Chen on 13-4-16.
//  Copyright (c) 2013年 emoney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPopupView.h"


/**
 *  具有标题、内容(webview)、单按钮、两个按钮多功能弹窗
 *  EMPopupView继承于EMPopupView, 自动弹框管理
 */

 NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSWebPopupView : MSPopupView <UIWebViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy)   ms_popupview_event_block_t leftBlock;
@property (nonatomic, copy)   ms_popupview_event_block_t rightBlock;
@property (nonatomic, strong, readonly) UIButton *leftBtn;
@property (nonatomic, strong, readonly) UIButton *rightBtn;


/**
 *  标题, 没有按钮的, 自动隐藏的
 *
 *  @param title 标题
 *
 *  @return EMWebPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title;


/**
 *  标题, 内容, 没有按钮的, 自动隐藏的
 *
 *  @param title   标题
 *  @param content 内容
 *
 *  @return EMWebPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title
                  contentText:(NSString *)content;


/**
 *  标题, 内容, 中间一个按钮
 *
 *  @param title       标题
 *  @param content     内容
 *  @param buttonTitle 中间按钮标题
 *  @param block       按钮block
 *
 *  @return EMWebPopupView 实例
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
 *  @return EMWebPopupView 实例
 */
- (instancetype)initWithTitle:(NSString *)title
                  contentText:(NSString *)content
              leftButtonTitle:(NSString *)leftTitle
                    leftBlock:( ms_popupview_event_block_t)leftBlock
             rightButtonTitle:(NSString *)rigthTitle
                   rightBlock:( ms_popupview_event_block_t)rightBlock;


- (void)show;
- (void)dismiss;


@end


NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSMaskBackgroundView : UIView
@property (nonatomic, weak) MSWebPopupView *popView;
@end
