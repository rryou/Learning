//
//  FreshMessageKeyboardController.m
//  FreshDemo
//
//  Created by zhang jinquan on 2/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "FreshMessageKeyboardController.h"
#import "BaseViewController.h"

static void *FreshKVO_MessageKeyboardFrameContext = &FreshKVO_MessageKeyboardFrameContext;

@interface FreshMessageKeyboardController ()
{
    BOOL _observingKeyboardState;
}

@end

@implementation FreshMessageKeyboardController

- (void)dealloc {
    [self uninstallObservers];
}

#pragma mark - Notifications

- (void)installObservers {
    if (!_observingKeyboardState) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        _observingKeyboardState = YES;
    }
}

- (void)uninstallObservers {
    if (_observingKeyboardState) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _observingKeyboardState = NO;
    }
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    [self handleKeyboardNotification:notification stateChangeComplete:nil];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    [_delegate keyboardControllerKeyboardWillHide:self];
    [self handleKeyboardNotification:notification stateChangeComplete:^(BOOL finished) {
        [_delegate keyboardControllerKeyboardDidHide:self];
    }];
}

- (void)handleKeyboardNotification:(NSNotification *)notification stateChangeComplete:(void (^)(BOOL finish))stateChangeComplete {
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = (UIViewAnimationCurve)[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self notifyKeyboardFrameNotificationForFrame:keyboardEndFrame];
                     }
                     completion:stateChangeComplete];
}

- (void)notifyKeyboardFrameNotificationForFrame:(CGRect)frame {
    [_delegate keyboardController:self didChangeFrame:frame];
}

#pragma mark - Public

- (void)beginObservingKeyboard {
    [self installObservers];
}

- (void)endObservingKeyboard {
    [self uninstallObservers];
}

@end

@implementation FreshSmartKeyboardController

- (void)installToViewController:(BaseViewController <FreshMessageKeyboardControllerDelegate> *)controller {
    self.delegate = controller;
    [controller addControllerObserver:self];
}

#pragma mark - ControllerObserveProtocol

- (void)controller:(UIViewController *)controller viewWillAppear:(BOOL)animated {
//    if (appContext.systemVersion < 8) {
        [self beginObservingKeyboard];
//    }
}

- (void)controller:(UIViewController *)controller viewDidAppear:(BOOL)animated {
   [self beginObservingKeyboard];
}

- (void)controller:(UIViewController *)controller viewWillDisappear:(BOOL)animated {
    [self endObservingKeyboard];
}

- (void)controller:(UIViewController *)controller viewDidDisappear:(BOOL)animated {
}

@end
