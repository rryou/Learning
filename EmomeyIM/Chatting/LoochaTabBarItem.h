//
//  LoochaTabBarItem.h
//  TabBarTest
//
//  Created by RealCloud on 14-8-14.
//  Copyright (c) 2014年 RealCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LoochaTabBarItem : NSObject

@property (nonatomic, getter = isEnabled) BOOL enabled;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, copy) NSString *title;

/**
 *  图片与文字（垂直对齐）默认为居中
 */
@property (nonatomic) UIOffset contentOffset;

/**
 *  默认为0，表示自动适应。若多个item的width之和大于tabBar的宽度，则width值无效。
 */
@property (nonatomic) CGFloat width;

/**
 *  item上红点中的内容，数字或其它字符（目前不支持显示内容。传入nil隐藏红点，非空值则显示）
 */
@property (nonatomic, copy) NSString *badgeValue;
@property (nonatomic) NSInteger tag;


- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;


// not implement yet
- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;
- (UIImage *)backgroundImageForState:(UIControlState)state;

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
- (NSDictionary *)titleTextAttributesForState:(UIControlState)state;

@end
