//
//  EMAlertPopupView.m
//  EMStock
//
//  Created by Samuel on 15/3/25.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSSystemAlertPopupView.h"
#import "MSPopupViewManager.h"
#import "MSPopupView.h"

@interface MSSystemAlertPopupView() {
    BOOL _isShowed;
}

@property (nonatomic, copy)   ms_popupview_event_block_t leftBlock;
@property (nonatomic, copy)   ms_popupview_event_block_t rightBlock;

@end


@implementation MSSystemAlertPopupView


- (void)show
{
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

- (void)showPopupView
{
    [super show];
    
    if (self.isAutoDismiss) {
        [self performSelector:@selector(dismissAfterDelay) withObject:nil afterDelay:self.autoDismissDelaySeconds];
    }
}

- (void)dismissAfterDelay
{
    [self dismissWithClickedButtonIndex:0 animated:NO];
    [self alertViewCancel:self];
}

// 出列, 然后显示下一个popup view
- (void)dequeueAndShowNextPopupView
{
    if (self.managedByQueue) {
        MSPopupViewManager *sharedManager = [MSPopupViewManager sharedManager];
        [sharedManager dequeuePopupView:self]; // 出列
        MSSystemAlertPopupView *popupView = (MSSystemAlertPopupView *)[sharedManager firstPopupView];
        if (popupView && ![popupView isDisplaying]) {
            [popupView performSelector:@selector(showPopupView)];
        }
    }
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.")
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
    }
    return self;
}



// 标题, 没有按钮的, 自动隐藏的, isAutoDismiss = YES
- (instancetype)initWithTitle:(NSString *)title
{
    self = [super initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        self.delegate = self;
        self.isAutoDismiss = YES;
        self.autoDismissDelaySeconds = 2.f;
        self.managedByQueue = YES;
    }
    
    return self;
}

// 标题, 内容, 没有按钮的, 自动隐藏的, isAutoDismiss = YES
- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
{
    self = [super initWithTitle:title message:content delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        self.delegate = self;
        self.isAutoDismiss = YES;
        self.autoDismissDelaySeconds = 2.f;
        self.managedByQueue = YES;
    }
    
    return self;
}


// 标题, 内容, 中间一个按钮
- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
        buttonTitle:(NSString *)buttonTitle
              block:( ms_popupview_event_block_t)block
{
    self = [super initWithTitle:title message:content delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:nil];
    if (self) {
        self.delegate = self;
        self.rightBlock = block;
        self.managedByQueue = YES;
    }
    
    return self;
}


// 标题, 内容, 两个按钮
- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
          leftBlock:( ms_popupview_event_block_t)leftBlock
   rightButtonTitle:(NSString *)rigthTitle
         rightBlock:( ms_popupview_event_block_t)rightBlock
{
    self = [super initWithTitle:title message:content delegate:self cancelButtonTitle:leftTitle otherButtonTitles:rigthTitle, nil];
    if (self) {
        self.delegate = self;
        self.leftBlock = leftBlock;
        self.rightBlock = rightBlock;
        self.managedByQueue = YES;
    }
    
    return self;
}


# pragma mark - delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && self.leftBlock) {
        self.leftBlock(nil);
    }
    else if (buttonIndex == 1 && self.rightBlock) {
        self.rightBlock(nil);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.rightBlock) {
        self.rightBlock(nil);
    }
    else if (self.leftBlock) {
        self.leftBlock(nil);
    }
    
}

- (BOOL)isDisplaying
{
    UIView *parentView = self.superview;
    for (UIView *v in parentView.subviews) {
        if (v == self) {
            return YES;
        }
    }
    
    return NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.managedByQueue) {
        [self dequeueAndShowNextPopupView];
    }
}

@end
