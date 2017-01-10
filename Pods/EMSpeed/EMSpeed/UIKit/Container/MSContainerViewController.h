//
//  MSContainerViewController.h
//  Pods
//
//  Created by flora on 16/4/13.
//
//一个带有menu支持点击切换，左右滑动切换controller的容器类

#import <EMSpeed/MSViewController.h>
#import "MSNavigationView.h"

@interface MSContainerViewController : MSViewController
{
    UIView<MSNavigatorView> *_navigationView;
}

@property(nullable, nonatomic,copy) NSArray<__kindof UIViewController *> *viewControllers;
@property(nullable, nonatomic, assign,readonly) __kindof UIViewController *currentController;

@property (nullable,nonatomic, strong, readonly) UIView<MSNavigatorView> *navigationView;

@property (assign, nonatomic) NSInteger selectedIndex;

/**
 *  之类复写的时候需要调用复类的方法
 *
 *  @param index 
 */
- (void)willSelectControllerAtIndex:(NSInteger)index;

- (void)didSelectControllerAtIndex:(NSInteger)index;

@end