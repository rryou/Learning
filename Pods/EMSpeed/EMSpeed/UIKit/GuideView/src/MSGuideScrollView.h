//
//  EMFunctionGuidView.h
//  EMStock
//
//  Created by xoHome on 14-10-20.
//  Copyright (c) 2014年 flora. All rights reserved.
//
//显示一个可滚动的功能引导页面
//支持滑动拉出、最后一张页面单点退出
//支持自定义的cell

#import <UIKit/UIKit.h>
#import "MSGuideScrollModel.h"
#import "MSGuideScrollUpdating.h"


typedef void(^MSGuidScrollCompletion)(void);

/**
 *  滚动引导视图
 */
@interface MSGuideScrollView : UIScrollView<UIScrollViewDelegate>
{
    NSArray *_items;
    NSArray *_cells;
}

@property (nonatomic, strong) MSGuidScrollCompletion completion;

/**
 *  不为CGRectZero时,缩小到endRect,然后消失
 */
@property (nonatomic, assign) CGRect endRect;


/**
 *  初始化
 *
 *  @param items 实现EMGuideScrollModel协议的对象数组
 *
 *  @return
 */
- (instancetype)initWithItems:(NSArray *)items;

+ (instancetype)showGuideScrollViewWithItems:(NSArray *)items
                                      InView:(UIView *)view
                                    fromRect:(CGRect)rect;

+ (instancetype)showGuideScrollViewWithItems:(NSArray *)items
                                      InView:(UIView *)view
                                    fromRect:(CGRect)rect
                                     endRect:(CGRect)endRect;

+ (instancetype)showGuideScrollViewWithItems:(NSArray *)items
                                      InView:(UIView *)view
                                    fromRect:(CGRect)rect
                            autoDismissDelay:(CGFloat)delay;


+ (instancetype)showGuideScrollViewWithItems:(NSArray *)items
                                      InView:(UIView *)view
                                    fromRect:(CGRect)rect
                                     endRect:(CGRect)endRect
                            autoDismissDelay:(CGFloat)delay;


+ (instancetype)showGuideScrollViewWithItems:(NSArray *)items
                                      InView:(UIView *)view
                                    fromRect:(CGRect)rect
                            autoDismissDelay:(CGFloat)delay
                                  completion:(void (^)(void))completion;


+ (instancetype)showGuideScrollViewWithItems:(NSArray *)items
                                      InView:(UIView *)view
                                    fromRect:(CGRect)rect
                                     endRect:(CGRect)endRect
                            autoDismissDelay:(CGFloat)delay
                                  completion:(void (^)(void))completion;


- (void)dismiss;


@end
