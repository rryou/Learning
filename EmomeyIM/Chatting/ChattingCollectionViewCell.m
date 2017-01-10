//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingCollectionViewCell.h"
#import "ChattingTipLabel.h"
#import <EMSpeed/MSUIKitCore.h>

const CGFloat kDateLabelHeight = 35;

@implementation ChattingCellDisplayAttribute

@end

@interface ChattingCollectionViewCell ()

@end

@implementation ChattingCollectionViewCell

@synthesize bottomView = _bottomView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kDateLabelHeight)];
        [self.contentView addSubview:_dateLabel];
        _dateLabel.backgroundColor = [UIColor clearColor];
        
        _dateLabel.textColor = RGB(252, 252, 252);
        _dateLabel.backgroundColor = RGB(195, 195, 195);
        _dateLabel.textAlignment = NSTextAlignmentCenter;

        _dateLabel.clipsToBounds = YES;
        _dateLabel.layer.cornerRadius = 3;
        _dateLabel.font = [UIFont systemFontOfSize:14];
        
        _bodyView = [[UIView alloc] init];
        [self.contentView addSubview:_bodyView];
        _bodyView.backgroundColor = [UIColor clearColor];
        _bodyView.clipsToBounds = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.contentView.bounds;
    _dateLabel.hidden = !_displayAttribute.showCellTopView;
    if (_displayAttribute.showCellTopView) {
        UIEdgeInsets ei = UIEdgeInsetsMake(0, 10, 10, 10);
        CGFloat maxDateWidth = r.size.width - 24;
        CGSize sz = [_dateLabel sizeThatFits:CGSizeMake(maxDateWidth - ei.left - ei.right, kDateLabelHeight)];
        sz.width += ei.left + ei.right;
        if (sz.width > maxDateWidth) {
            sz.width = maxDateWidth;
        }
        _dateLabel.frame = CGRectMake((r.size.width - sz.width)/2, ei.top, sz.width, sz.height + 4 + 4);
        
        r.origin.y = kDateLabelHeight;
        r.size.height -= kDateLabelHeight;
    }
    if (_bottomView) {
        _bottomView.frame = CGRectMake(0, CGRectGetMaxY(r) - _displayAttribute.bottomViewHeight, r.size.width, _displayAttribute.bottomViewHeight);
        r.size.height -= _displayAttribute.bottomViewHeight;
    }
    _bodyView.frame = r;
}

- (void)setDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute {
    _displayAttribute = displayAttribute;
    [self setNeedsLayout];
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        [self.contentView addSubview:_bottomView];
    }
    return _bottomView;
}

+ (CGFloat)cellHeightWithDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute cellContext:(ChattingCellContext *)cellContext {
    return (displayAttribute.showCellTopView ? kDateLabelHeight : 0) + displayAttribute.bottomViewHeight;
}

@end
