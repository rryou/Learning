//
//  EMFunctionGuidView.h
//  EMStock
//
//  Created by xoHome on 14-10-21.
//  Copyright (c) 2014年 flora. All rights reserved.
//类型1：显示所有子元素
//类型2：依次自动显示所有子元素

#import <UIKit/UIKit.h>

extern const CGFloat kGuidViewShowInterval;

typedef void(^MSGuideViewCompletion)(void);

@interface MSSingleGuideView : UIView

@property (nonatomic, strong) MSGuideViewCompletion completion;



/**
 *  单点功能引导界面, 可支持多个连续动画播放
 *
 *  @param array      数组
 *  @param view       在哪个界面上显示
 *  @param automatic  自动隐藏
 *  @param completion 动画完成后执行的闭包
 *
 *  @return 单点功能引导界面
 */
+ (MSSingleGuideView *)showSingleGuidViewWithitems:(NSArray *)array
                                            inView:(UIView *)view
                              dismissAutomatically:(BOOL)automatic
                                        completion:(void (^)(void))completion;


+ (MSSingleGuideView *)showSingleGuideViewInWithItems:(NSArray *)items
                                               inView:(UIView *)view;
- (void)dismiss;

@end


@interface EMSingleGuideItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGPoint point;

@end
