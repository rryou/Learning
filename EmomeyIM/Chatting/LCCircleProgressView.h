//
//  LCCircleProgressView.h
//  LoochaCampusMain
//
//  Created by ChenHao on 15/5/29.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCCircleProgressView : UIView

/**
 *  进度条颜色，默认为黑色
 */
@property (nonatomic, strong) UIColor* progressTintColor;

/**
 *  circle背景色，默认为nil（不显示）
 */
@property (nonatomic, strong) UIColor* trackTintColor;

/**
 *  边的宽度，默认值为2。
 */
@property (nonatomic) CGFloat lineWidth;

/**
 *  进度，0～1之间
 */
@property (nonatomic) float progress;


- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
