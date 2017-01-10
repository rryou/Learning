//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ChattingIncomingCell.h"

static const CGFloat kAvatarWidth = 40;
static const CGFloat kNameHeight = 20;
static const CGFloat kBubbleMarginX = 10;
static const CGFloat kBubbleMarginY = 5;

#define kBubbleEdgeInsets UIEdgeInsetsMake(2, 6, 2, 2)

@implementation ChattingIncomingCell{
    ChattingBubbleStyle _chattingBubbleStyle;
}

- (void)setChattingBubbleStyle:(ChattingBubbleStyle)chattingBubbleStyle {
    if (_chattingBubbleStyle != chattingBubbleStyle) {
        _chattingBubbleStyle = chattingBubbleStyle;
        
        if (_chattingBubbleStyle == ChattingBubbleStyle_None) {
            self.bubbleImageView.hidden = YES;
        }
        
        else {
            self.bubbleImageView.hidden = NO;
            
            if (_chattingBubbleStyle == ChattingBubbleStyle_Hollow) {
                self.bubbleImageView.image = [[UIImage imageNamed:@"pm_otherBubble_hollow"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
                self.bubbleImageView.highlightedImage = [[UIImage imageNamed:@"pm_otherBubble_hollow_touch"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
            }
            else if (_chattingBubbleStyle == ChattingBubbleStyle_WhiteBubble) {
                self.bubbleImageView.image = [[UIImage imageNamed:@"pm_otherBubble_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
                self.bubbleImageView.highlightedImage = [[UIImage imageNamed:@"pm_otherBubble_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
            }
            else {
                self.bubbleImageView.image = [[UIImage imageNamed:@"pm_otherBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
                self.bubbleImageView.highlightedImage = [[UIImage imageNamed:@"pm_otherBubble_touch"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
            }
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[RoundAvatarView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWidth, kAvatarWidth)];
        [self.bodyView addSubview:_avatarView];
        _avatarView.backgroundColor = [UIColor clearColor];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAvatarWidth, 0, frame.size.width - kAvatarWidth, kNameHeight)];
        [self.bodyView addSubview:_nameLabel];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor grayColor];
//        [self setChattingBubbleStyle:ChattingBubbleStyle_Normal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize bodySize = self.bodyView.frame.size;
    CGSize msgContentSize = self.displayAttribute.msgContentSize;
    
    UIEdgeInsets bubbleContentEdgeInsets = [[self class] bubbleContentEdgeInsetsForDisplayAttribute:self.displayAttribute];
    self.avatarView.frame = CGRectMake(12, 0, kAvatarWidth, kAvatarWidth);
    CGFloat y = 0;
    self.nameLabel.hidden = !self.cellContext.showIncomingUserName;
    if (!_nameLabel.hidden) {
        self.nameLabel.frame = CGRectMake(12 + kAvatarWidth + kBubbleMarginX, y, bodySize.width - 12 - kAvatarWidth - kBubbleMarginX, kNameHeight);
        y += kNameHeight + kBubbleMarginY;
    }
    self.contentFrameView.frame = CGRectMake(12 + kAvatarWidth + kBubbleMarginX, y,
                                            msgContentSize.width + bubbleContentEdgeInsets.left + bubbleContentEdgeInsets.right,
                                            msgContentSize.height + bubbleContentEdgeInsets.top + bubbleContentEdgeInsets.bottom);
    self.contentContainerView.frame = CGRectMake(bubbleContentEdgeInsets.left, bubbleContentEdgeInsets.top, msgContentSize.width, msgContentSize.height);
    self.chattingContentView.frame = CGRectMake(0, 0, msgContentSize.width, msgContentSize.height);
}

- (void)setDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute {
    [super setDisplayAttribute:displayAttribute];
    [self setChattingBubbleStyle:displayAttribute.bubbleStyle];
}

+ (CGFloat)cellHeightWithDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute cellContext:(ChattingCellContext *)cellContext {
    CGFloat h = [super cellHeightWithDisplayAttribute:displayAttribute cellContext:cellContext];
    UIEdgeInsets bubbleContentEdgeInsets = [self bubbleContentEdgeInsetsForDisplayAttribute:displayAttribute];
    h += displayAttribute.msgContentSize.height + bubbleContentEdgeInsets.top + bubbleContentEdgeInsets.bottom;
    if (cellContext.showIncomingUserName) {
        h += kNameHeight + kBubbleMarginY;
    }
    return h;
}

+ (UIEdgeInsets)bubbleContentEdgeInsetsForDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute {
    return displayAttribute.bubbleStyle == ChattingBubbleStyle_None ? UIEdgeInsetsZero : kBubbleEdgeInsets;
}

@end
