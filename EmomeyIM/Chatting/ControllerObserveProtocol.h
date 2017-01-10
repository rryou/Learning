//
//  ControllerObserveProtocol.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 11/22/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControllerObserveProtocol <NSObject>

@optional

- (void)controller:(UIViewController *)controller viewWillAppear:(BOOL)animated;
- (void)controller:(UIViewController *)controller viewDidAppear:(BOOL)animated;

- (void)controller:(UIViewController *)controller viewWillDisappear:(BOOL)animated;
- (void)controller:(UIViewController *)controller viewDidDisappear:(BOOL)animated;

@end
