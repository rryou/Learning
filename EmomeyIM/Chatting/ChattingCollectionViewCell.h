//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "ChattingCellContext.h"

typedef enum {
    ChattingBubbleStyle_Default, // 同ChattingBubbleStyle_Normal
    ChattingBubbleStyle_Normal,  // 常规气泡
    ChattingBubbleStyle_Hollow,  // 空心气泡
    ChattingBubbleStyle_WhiteBubble, //收发都是白色边框
    ChattingBubbleStyle_None,    // 不显示气泡
} ChattingBubbleStyle;

@interface ChattingCellDisplayAttribute : NSObject

@property (nonatomic, assign) BOOL showCellTopView;
@property (nonatomic, assign) CGSize msgContentSize;
@property (nonatomic, assign) CGFloat bottomViewHeight;
@property (nonatomic, assign) ChattingBubbleStyle bubbleStyle;

@end

@interface ChattingCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) ChattingCellContext *cellContext;
// 日期分割
@property (nonatomic, readonly) UILabel *dateLabel;
// cell主体
@property (nonatomic, readonly) UIView *bodyView;
// cell底部视图
@property (nonatomic, readonly) UIView *bottomView;
// 显示属性
@property (nonatomic, strong) ChattingCellDisplayAttribute *displayAttribute;

+ (CGFloat)cellHeightWithDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute cellContext:(ChattingCellContext *)cellContext;

@end
