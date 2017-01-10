//
//  LoochaTabBar.h
//  TabBarTest
//
//  Created by RealCloud on 14-8-14.
//  Copyright (c) 2014年 RealCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoochaTabBarItem.h"

#define kTabBarDefaultHeight 57
#define kTabBarItemDefaultHeight 50
#define kTabBarProgressWidth 46

@class LoochaTabBar;

@protocol LoochaTabBarDelegate <NSObject>

- (void)tabBar:(LoochaTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

@optional
- (void)tabBarDidClickOnCenterButton:(LoochaTabBar *)tabBar;
- (BOOL)tabBar:(LoochaTabBar *)tabBar canSelectItemAtIndex:(NSInteger)index;

@end

@protocol LoochaTabBarItemProtocol <NSObject>

@property (nonatomic) CGFloat width;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@optional
/**
 *  item上红点中的内容，数字或其它字符（目前不支持显示内容。传入nil隐藏红点，非空值则显示）
 */
@property (nonatomic, copy) NSString *badgeValue;

@end


@interface LoochaTabBar : UIView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSInteger selectedItemIndex;
@property (nonatomic, readonly) NSInteger lastSelectedItemIndex;

@property (nonatomic, strong, readonly) UIButton *centerButton;
@property (nonatomic) CGFloat centerButtonWidth;

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, weak) id<LoochaTabBarDelegate> delegate;
@property (nonatomic, readonly) UIImageView *showImageView;

- (instancetype)initWithItems:(NSArray *)items;

- (instancetype)initWithCustomItemViews:(NSArray *)items;

- (instancetype)initWithFrame:(CGRect)frame customItemViews:(NSArray *)items;

/**
 *  设置tabBar上对应item的红点
 *
 *  @param badgeValue 红点中的内容（目前不支持显示内容。传入nil隐藏红点，非空值则显示）
 *  @param index      item的索引
 */
- (void)setBadgeValue:(NSString *)badgeValue atIndex:(int)index;

- (void)selectItemIndex:(NSInteger)selectedItemIndex;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

- (void)beginProgress;
- (void)setProgress:(CGFloat)progress;
- (void)endProgress;

/**
 *  震动tabBar
 */
- (void)vibrate;

@end
