//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingMessageCell.h"

#import "RoundAvatarView.h"

@interface ChattingIncomingCell : ChattingMessageCell

@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) RoundAvatarView *avatarView;

+ (UIEdgeInsets)bubbleContentEdgeInsetsForDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute;
- (void)setChattingBubbleStyle:(ChattingBubbleStyle)chattingBubbleStyle;
@end
