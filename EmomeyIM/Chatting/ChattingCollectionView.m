//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingCollectionView.h"

@implementation ChattingCellAction

- (void)excute {
    if (_handler) {
        _handler();
    }
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(dispatch_block_t)handler {
    ChattingCellAction *action = [[ChattingCellAction alloc] init];
    action.title = title;
    action.handler = handler;
    return action;
}

@end

@implementation ChattingCollectionView

@dynamic delegate;
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (NSIndexPath *)indexPathForDescendantOfView:(UIView *)descendantOfView {
    if ([descendantOfView isDescendantOfView:self]) {
        CGPoint pt = [self convertPoint: descendantOfView.center fromView:descendantOfView];
        return [self indexPathForItemAtPoint:pt];
    }
    return nil;
}

@end
