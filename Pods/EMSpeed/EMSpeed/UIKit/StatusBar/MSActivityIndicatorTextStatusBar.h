//
//  EMActivatorTextStatusBar.h
//  UI
//
//  Created by Samuel on 15/4/10.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSStatusBarUpdating.h"


@interface MSActivityIndicatorTextStatusBar : UIView <MSStatusBarUpdating> 

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end
