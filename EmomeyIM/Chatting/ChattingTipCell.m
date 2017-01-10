//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingTipCell.h"

@implementation ChattingTipCell

- (void)prepareChattingContentViewForReuse {
    if (_tipCntentView) {
        [_tipCntentView removeFromSuperview];
        [self.cellContext enqueueReusableView:_tipCntentView];
        _tipCntentView = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sz = self.bodyView.frame.size;
    CGSize msgContentSize = self.displayAttribute.msgContentSize;
    _tipCntentView.frame = CGRectMake((sz.width - msgContentSize.width)/2, (sz.height - msgContentSize.height)/2, msgContentSize.width, msgContentSize.height);
}

- (void)setTipCntentView:(UIView<ReusableViewProtocol> *)tipCntentView {
    if (_tipCntentView != tipCntentView) {
        [self prepareChattingContentViewForReuse];
        
        _tipCntentView = tipCntentView;
        [self.bodyView addSubview:_tipCntentView];
    }
}

+ (CGFloat)cellHeightWithDisplayAttribute:(ChattingCellDisplayAttribute *)displayAttribute cellContext:(ChattingCellContext *)cellContext {
    CGFloat h = [super cellHeightWithDisplayAttribute:displayAttribute cellContext:cellContext];
    h += displayAttribute.msgContentSize.height;
    return h;
}

@end
