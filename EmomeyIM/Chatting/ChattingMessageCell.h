//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingCollectionViewCell.h"

@interface ChattingMessageCell : ChattingCollectionViewCell

// 内容显示框架视图，展示气泡、内容等，用于组织聊天内容的视图
@property (nonatomic, readonly) UIView *contentFrameView;

// 实际内容视图的容器，内容视图加载在该视图上
@property (nonatomic, readonly) UIView *contentContainerView;

// 气泡
@property (nonatomic, readonly) UIImageView *bubbleImageView;
// 气泡内容视图，实际内容添加在该视图之上
//@property (nonatomic, readonly) UIView *bubbleContentView;
// 添加在bubbleContentView之上的实际内容
@property (nonatomic, strong) UIView<ReusableViewProtocol> *chattingContentView;
@property (nonatomic, strong) UIView<ReusableViewProtocol> *chattingBottomContentView;

@end
