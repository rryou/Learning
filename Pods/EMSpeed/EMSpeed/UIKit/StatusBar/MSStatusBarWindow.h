//
//  MSTextStatusBar.h
//  YCStock
//
//  Created by meiosis chen on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSStatusBarUpdating.h"
#import "MSStatusBarModel.h"

/**
 *  状态栏文字窗口
 */
NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSStatusBarWindow : UIWindow
{
    UIView<MSStatusBarUpdating> *_statusBar0;
    UIView<MSStatusBarUpdating> *_statusBar1;
    BOOL _isSwaped;
    
    BOOL _isAnimating;
    NSMutableArray *_array;
}

@property (nonatomic, assign) BOOL isAutoHidden; // 播放到最后一个时是否自动隐藏, 默认YES

+ (MSStatusBarWindow *)sharedManager;

+ (void)showStatusBarWithModel:(id<MSStatusBarModel>)data;
+ (void)showStatusBarWithArray:(NSArray *)array; // id<MSStatusBarModel> 数组

+ (void)hiddenStatusBarAnimated:(BOOL)animated;


@end
