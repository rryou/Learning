//
//  MSContainerView.h
//  NetEaseNews
//
//  Created by flora on 16/3/18.
//  Copyright © 2016年 WackoSix. All rights reserved.
//管理多个controller 左右滚动，自带可滚动的menu可用于切换菜单

#import <UIKit/UIKit.h>
#import "MSNavigationView.h"

@interface MSContainerView : UIView
{
    UIView<MSNavigatorView> *_navigationView;
}

@property (nonatomic, strong, readonly) UIView<MSNavigatorView> *navigationView;
@property (assign, nonatomic) NSInteger selectedIndex;


/**
 *  
 *
 *  @param viewControllers
 *  @param navigationClass 导航条的类型
 *
 *  @return
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers navigationClass:(Class<MSNavigatorView>)navigationClass;

/**
 *  采用默认的navigationView
 *
 *  @param viewControllers 显示的一组controller
 *
 *  @return
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;


/**
 *  获取当前显示的controller
 *
 *  @return
 */
- (UIViewController *)currentController;

@end
