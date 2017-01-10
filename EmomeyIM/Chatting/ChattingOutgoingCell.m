//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingOutgoingCell.h"

static const CGFloat kAvatarWidth = 40;
static const CGFloat kBubbleMargin = 10;
static const CGFloat kStatusWidth = 30;

#define kBubbleEdgeInsets UIEdgeInsetsMake(2, 2, 2, 6) // UIEdgeInsetsMake(10, 10, 10, 13)

@interface ChattingOutgoingCell ()
{
    UIActivityIndicatorView *_sendingStatusView;
    UIButton *_failedStatusView;
    ChattingBubbleStyle _chattingBubbleStyle;
}

@property (nonatomic, readonly) UIActivityIndicatorView *sendingStatusView;
@property (nonatomic, readonly) UIButton *failedStatusView;

@end

@implementation ChattingOutgoingCell

- (void)setChattingBubbleStyle:(ChattingBubbleStyle)chattingBubbleStyle {
    if (_chattingBubbleStyle != chattingBubbleStyle) {
        _chattingBubbleStyle = chattingBubbleStyle;
        
        if (_chattingBubbleStyle == ChattingBubbleStyle_None) {
            self.bubbleImageView.hidden = YES;
        }
        else {
            self.bubbleImageView.hidden = NO;
            
            if (_chattingBubbleStyle == ChattingBubbleStyle_Hollow) {
                self.bubbleImageView.image = [[UIImage imageNamed:@"pm_selfBubble_hollow"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
                self.bubbleImageView.highlightedImage = [[UIImage imageNamed:@"pm_selfBubble_hollow_touch"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
            }
            else {
                self.bubbleImageView.image = [[UIImage imageNamed:@"pm_selfBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
                self.bubbleImageView.highlightedImage = [[UIImage imageNamed:@"pm_selfBubble_touch"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 10)];
            }
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_sendingStatusView stopAnimating];
}

- (UIActivityIndicatorView *)sendingStatusView {
    if (_sendingStatusView == nil) {
        _sendingStatusView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.bodyView addSubview:_sendingStatusView];
        _sendingStatusView.hidden = YES;
    }
    return _sendingStatusView;
}

- (UIButton *)failedStatusView {
    if (_failedStatusView == nil) {
        _failedStatusView = [[UIButton alloc] init];
        [self.bodyView addSubview:_failedStatusView];
        [_failedStatusView setImage:[UIImage imageNamed:@"chatting_cell_outgoing_failed"] forState:UIControlStateNormal];
        [_failedStatusView addTarget:self action:@selector(actionPressFailedButton) forControlEvents:UIControlEventTouchUpInside];
        _failedStatusView.hidden = YES;
    }
    return _failedStatusView;
}

- (void)setOutgoingStatus:(ChattingOutgoingStatus)outgoingStatus {
    _outgoingStatus = outgoingStatus;
    
    switch (_outgoingStatus) {
        case ChattingOutgoingStatus_Normal:
            [_sendingStatusView stopAnimating];
            _sendingStatusView.hidden = YES;
            _failedStatusView.hidden = YES;
            break;
            
        case ChattingOutgoingStatus_Sending:
            [self.sendingStatusView startAnimating];
            _sendingStatusView.hidden = NO;
            _failedStatusView.hidden = YES;
            break;
            
        case ChattingOutgoingStatus_Failed:
            _sendingStatusView.hidden = YES;
            self.failedStatusView.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (void)actionPressFailedButton {
    ChattingCollectionView *chattingCollectionView = self.cellContext.chattingCollectionView;
    if ([chattingCollectionView.delegate respondsToSelector:@selector(collectionView:didPressFailedButtonOnCellAtIndexPath:)]) {
        [chattingCollectionView.delegate collectionView:chattingCollectionView didPressFailedButtonOnCellAtIndexPath:[chattingCollectionView indexPathForCell:self]];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[RoundAvatarView alloc] initWithFrame:CGRectMake(frame.size.width - kAvatarWidth, 0, kAvatarWidth, kAvatarWidth)];
        [self.bodyView addSubview:_avatarView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = self.bodyView.frame.size;
    CGSize msgContentSize = self.displayAttribute.msgContentSize;
    
//    UIEdgeInsets bubbleContentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 13);
    UIEdgeInsets bubbleContentEdgeInsets = [[self class] bubbleContentEdgeInsetsForDisplayAttribute:self.displayAttribute];
    self.avatarView.frame = CGRectMake(maxSize.width - kAvatarWidth - 12, 0, kAvatarWidth, kAvatarWidth);
    self.contentFrameView.frame = CGRectMake(maxSize.width - msgContentSize.width - bubbleContentEdgeInsets.left - bubbleContentEdgeInsets.right - kAvatarWidth - 12 - kBubbleMargin, 0,
                                            msgContentSize.width + bubbleContentEdgeInsets.left + bubbleContentEdgeInsets.right,
                                            msgContentSize.height + bubbleContentEdgeInsets.top + bubbleContentEdgeInsets.bottom);
    self.contentContainerView.frame = CGRectMake(bubbleContentEdgeInsets.left, bubbleContentEdgeInsets.top, msgContentSize.width, msgContentSize.height);
    self.chattingContentView.frame = CGRectMake(0, 0, msgContentSize.width, msgContentSize.height);
    
    if (_sendingStatusView && !_sendingStatusView.hidden) {
        _sendingStatusView.frame = [self statusFrame];
    }
    if (_failedStatusView && !_failedStatusView.hidden) {
        _failedStatusView.frame = [self statusFrame];
    }
}

- (void)setDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute {
    [super setDisplayAttribute:displayAttribute];
    [self setChattingBubbleStyle:displayAttribute.bubbleStyle];
}

- (CGRect)statusFrame {
    CGRect r = self.contentFrameView.frame;
    return CGRectMake(r.origin.x - kBubbleMargin - kStatusWidth, r.origin.y + (r.size.height - kStatusWidth)/2, kStatusWidth, kStatusWidth);
}

+ (CGFloat)cellHeightWithDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute cellContext:(ChattingCellContext *)cellContext {
    CGFloat h = [super cellHeightWithDisplayAttribute:displayAttribute cellContext:cellContext];
    UIEdgeInsets bubbleContentEdgeInsets = [self bubbleContentEdgeInsetsForDisplayAttribute:displayAttribute];
    h += displayAttribute.msgContentSize.height + bubbleContentEdgeInsets.top + bubbleContentEdgeInsets.bottom;
    return h;
}

+ (UIEdgeInsets)bubbleContentEdgeInsetsForDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute {
    return displayAttribute.bubbleStyle == ChattingBubbleStyle_None ? UIEdgeInsetsZero : kBubbleEdgeInsets;
}

@end
