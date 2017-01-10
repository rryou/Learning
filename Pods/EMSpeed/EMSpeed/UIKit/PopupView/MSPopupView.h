//
//  EMPopupView.h
//  EMStock
//
//  Created by Samuel on 15/3/24.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import <UIKit/UIKit.h>




/**
 *  弹框基类, 只要继承就可以拥有
 *  具有队列管理功能, 多个弹框时, 一个接着一个弹框, 
 *  可支持自动隐藏
 */
NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSPopupView : UIView {
    BOOL _managedByQueue; // 由队列管理, 依次弹, 默认YES
    UIView *_parentView; // 父view
}

/**
 *  由队列管理, 默认YES, 调用show后再设置是无效的
 */
@property (nonatomic, assign) BOOL managedByQueue;


/**
 *  是否自动消失
 */
@property (nonatomic, assign) BOOL isAutoDismiss;


/**
 *  自动消失延迟时间, 默认2秒
 */
@property (nonatomic, assign) float autoDismissDelaySeconds;


/**
 *  显示弹框
 */
- (void)show;


/**
 *  关闭弹框
 */
- (void)dismiss;


/**
 *  是否正在显示
 *
 *  @return 是否正在显示
 */
- (BOOL)isDisplaying;


/**
 *  子类可重写, 默认是在keywindow上的, 你也可以加在controller的view上
 *
 *  @return 父view
 */
- (UIView *)parentView;


/**
 *  清空弹框队列, 解散当前的弹框
 */
+ (void)dismissAndDequeueAllPopupViews;

@end

/**
 *  点击事件的block
 *  @param view 弹框视图
 */
typedef void (^ms_popupview_event_block_t)(MSPopupView *view) NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.");


