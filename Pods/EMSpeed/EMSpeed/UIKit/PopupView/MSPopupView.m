//
//  EMPopupView.m
//  EMStock
//
//  Created by Samuel on 15/3/24.
//  Copyright (c) 2015年 flora. All rights reserved.
//


#import "MSPopupView.h"
#import "MSPopupViewManager.h"

@interface MSPopupView() {
    BOOL _isShowed;
}

- (void)showPopupView;
- (void)dismissPopupView;

@end


@implementation MSPopupView

@dynamic managedByQueue;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _managedByQueue = YES;
        _isShowed = NO;
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _managedByQueue = YES;
    _isShowed = NO;
}


-(BOOL)managedByQueue
{
    return _managedByQueue;
}


-(void)setManagedByQueue:(BOOL)managedByQueue
{
    if (!_isShowed) {
        // 显示过了 就不能再设置了
        _managedByQueue = managedByQueue;
    }
}


- (UIView *)parentView
{
    // 这样写 怕keywindow变化
    if (_parentView == nil) {
        _parentView = [UIApplication sharedApplication].keyWindow;
    }
    return _parentView;
}


- (void)showPopupView
{
    [[self parentView] addSubview:self];
    
    self.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (_isAutoDismiss) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:_autoDismissDelaySeconds];
        }
    }];
}


- (void)dismissPopupView
{
    self.alpha = 1.f;
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.managedByQueue) {
            [self dequeueAndShowNextPopupView];
        }
        _isShowed = NO;
    }];
}


- (BOOL)isDisplaying
{
    if (_parentView) {
        for (UIView *v in _parentView.subviews) {
            if (v == self) {
                return YES;
            }
        }
    }
    
    return NO;
}


- (void)show
{
    // 显示之后就不能再修改 managedByQueue, 以免消失后不平衡
    _isShowed = YES;
    
    if (self.managedByQueue) {
        // 然后显示队列中第一个
        MSPopupViewManager *sharedManager = [MSPopupViewManager sharedManager];
        
        // 先加入队列
        BOOL successful = [sharedManager enqueuePopupView:self];
        if (successful && self == [sharedManager firstPopupView]) {
            // 如果当前是第一个, 则显示
            [self showPopupView];
        }
    }
    else {
        [self showPopupView];
    }
}


- (void)dismiss
{
    [self dismissPopupView];
}


// 出列, 然后显示下一个popup view
- (void)dequeueAndShowNextPopupView
{
    if (self.managedByQueue) {
        MSPopupViewManager *sharedManager = [MSPopupViewManager sharedManager];
        [sharedManager dequeuePopupView:self]; // 出列
        MSPopupView *popupView = (MSPopupView *)[sharedManager firstPopupView];
        if (popupView && ![popupView isDisplaying]) {
            [popupView showPopupView];
        }
    }

}


+ (void)dismissAndDequeueAllPopupViews
{
    MSPopupViewManager *sharedManager = [MSPopupViewManager sharedManager];
    [sharedManager dequeueAll];
    
    UIView *view = [sharedManager firstPopupView];
    if ([view respondsToSelector:@selector(dismiss)]) {
        [view performSelector:@selector(dismiss)];
    }
}

@end

