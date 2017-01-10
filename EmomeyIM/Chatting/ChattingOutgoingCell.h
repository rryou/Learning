//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingMessageCell.h"

#import "RoundAvatarView.h"

typedef enum {
    ChattingOutgoingStatus_Normal,
    ChattingOutgoingStatus_Sending,
    ChattingOutgoingStatus_Failed
} ChattingOutgoingStatus;

@interface ChattingOutgoingCell : ChattingMessageCell

@property (nonatomic, readonly) RoundAvatarView *avatarView;
@property (nonatomic, assign) ChattingOutgoingStatus outgoingStatus;
- (void)setChattingBubbleStyle:(ChattingBubbleStyle)chattingBubbleStyle;
@end
