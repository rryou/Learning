//
//  EMActivityIndicatorTextData.h
//  UI
//
//  Created by Samuel on 15/4/10.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSStatusBarModel.h"

@interface MSActivityIndicatorTextModel : NSObject <MSStatusBarModel>

@property (nonatomic, assign) BOOL isActivityIndicatorAnimating; // 是否有动画
@property (nonatomic, assign) BOOL hasActivityIndicator; // 是否有loading

- (UIView<MSStatusBarUpdating> *)statusBarWithData:(id<MSStatusBarModel>)data;
@end
