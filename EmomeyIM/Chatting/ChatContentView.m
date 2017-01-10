//
//  ChatContentView.m
//  LoochaCampusMain
//
//  Created by 陈易侗 on 15/4/20.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import "ChatContentView.h"
#import "ChattingContent.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import <EMSpeed/MSUIKitCore.h>

#import "TTLoochaStyledTextLabel.h"

@interface ChatContentView()
{
    
}

@property (nonatomic,strong) UIImageView *iconImage;
@property (nonatomic,strong) TTLoochaStyledTextLabel *contentL;
@property (nonatomic,strong) UIView *itemView;
@property (nonatomic,strong) UIButton *appBtn;
@property (nonatomic,strong) NSString *despiseId;
@end

const CGFloat titleHeight = 22.0;
const CGFloat imageDefaultHeight = 64.0;

@implementation ChatContentView
@synthesize reuseIdentifier;

- (void)dealloc
{
    self.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)prepareForReuse {
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, titleHeight)];
        _titleLabel.font = [UIFont systemFontOfSize:13.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _titleLabel;
}

- (TTLoochaStyledTextLabel *)contentL {
    if(!_contentL) {
        _contentL = [[TTLoochaStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, 100, titleHeight)];
        _contentL.font = [UIFont systemFontOfSize:14.0];
        _contentL.textColor = RGB(246, 246, 246);
        _contentL.backgroundColor = [UIColor clearColor];
    }
    
    return _contentL;
}

- (UIImageView *)iconImage {
    if(!_iconImage) {
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _iconImage.backgroundColor = RGB(246, 246, 246);
        _iconImage.contentMode = UIViewContentModeScaleAspectFill;
        _iconImage.clipsToBounds = YES;
    }
    
    return _iconImage;
}

- (UIView *)itemView {
    if(!_itemView) {
        _itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, titleHeight)];
        _itemView.backgroundColor =  RGB(246, 246, 246);
        _itemView.layer.cornerRadius = 3.0;
    }
    
    return _itemView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#define appHeight   26.0

- (void)updateWithContent:(ChattingContent *)content
                messageID:(NSString *)messageID
             withMaxWidth:(int)maxWidth
{
    [_iconImage sd_setImageWithURL:nil placeholderImage:nil options:0];
    
    for(UIView *tmp in _itemView.subviews) {
        [tmp removeFromSuperview];
    }
    
    CGFloat gap = 6.0;
    CGFloat y = 0.0;
    CGSize sz = [ChatContentView viewSizeWithContent:content maxWidth:maxWidth];
    
    if([self isTitleShowWithContent:content]) {
        
        if(!_titleLabel) {
            [self addSubview:self.titleLabel];
        }
        
        if(!_titleLabel.superview) {
            [self addSubview:_titleLabel];
        }
        
        _titleLabel.hidden = NO;
        _titleLabel.text = [self getTitleContentWithContent:content];
        
        y += [ChatContentView getTitleHeightWithContent:content];
    }
    else {
        _titleLabel.hidden = YES;
    }
    
    // 灰色背景view
    if(!_itemView) {
        [self addSubview:self.itemView];
    }
    else {
        if(!_itemView.superview) {
            [self addSubview:self.itemView];
        }
    }
    
    // icon
    if(!_iconImage) {
        [_itemView addSubview:self.iconImage];
    }
    else {
        if(!_iconImage.superview) {
            [_itemView addSubview:self.iconImage];
        }
    }
    
    // 文字描述
    if(!_contentL) {
        [_itemView addSubview:self.contentL];
    }
    else {
        if(!_contentL.superview) {
            [_itemView addSubview:self.contentL];
        }
    }
    
    _appBtn.hidden = YES;
    _iconImage.hidden = YES;
    
    CGRect r = self.frame;
    r.size.height = y;
    r.size.width = maxWidth;
    self.frame = r;
}

- (void)actionToLink:(UIButton *)sender{
}


+ (CGFloat)getTitleHeightWithContent:(ChattingContent *)content{
    CGFloat height = 0.0;
    return height;
}

- (NSString *)getTitleContentWithContent:(ChattingContent *)content
{
    NSString *title = nil;
    return title;
}

- (BOOL)isTitleShowWithContent:(ChattingContent *)content{
        return NO;
}

+ (CGSize)viewSizeWithContent:(id)content maxWidth:(CGFloat)maxWidth{
    ChattingContent *chat = (ChattingContent *)content;
    
    CGFloat gap = 6;
    UIEdgeInsets ei = UIEdgeInsetsMake(gap, 6, gap, 6);
    
    CGSize sz = [TTLoochaStyledTextLabel viewSizeWithContent:chat.text
                                             constraintWidth:maxWidth - ei.left - ei.right
                                                withFontSize:12.0
                                                withMaxLines:4
                                                 isMePublish:NO
                                                 withGiftArr:nil];
    return sz;
}

@end
