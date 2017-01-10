//
//  FreshMessageKeyboardController.h
//  FreshDemo
//
//  Created by zhang jinquan on 2/10/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ControllerObserveProtocol.h"

@class FreshMessageKeyboardController;

@protocol FreshMessageKeyboardControllerDelegate <NSObject>

- (void)keyboardController:(FreshMessageKeyboardController *)keyboardController didChangeFrame:(CGRect)keyboardFrame;

- (void)keyboardControllerKeyboardWillHide:(FreshMessageKeyboardController *)keyboardController;

- (void)keyboardControllerKeyboardDidHide:(FreshMessageKeyboardController *)keyboardController;

@end

@interface FreshMessageKeyboardController : NSObject

@property (nonatomic, weak) id<FreshMessageKeyboardControllerDelegate> delegate;

- (void)beginObservingKeyboard;

- (void)endObservingKeyboard;

@end

@interface FreshSmartKeyboardController : FreshMessageKeyboardController <ControllerObserveProtocol>

- (void)installToViewController:(UIViewController<FreshMessageKeyboardControllerDelegate> *)controller;

@end
