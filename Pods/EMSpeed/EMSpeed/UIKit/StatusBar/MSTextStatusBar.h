//
//  EMStatusBarLabel.h
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSStatusBarUpdating.h"

NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface MSTextStatusBar : UIView <MSStatusBarUpdating>

@property (nonatomic, strong) UILabel *titleLabel;

- (void)updateStatusBar:(id<MSStatusBarModel>)model;

@end
