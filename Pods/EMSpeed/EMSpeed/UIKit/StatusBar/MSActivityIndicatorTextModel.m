//
//  EMActivityIndicatorTextData.m
//  UI
//
//  Created by Samuel on 15/4/10.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSActivityIndicatorTextModel.h"
#import "MSActivityIndicatorTextStatusBar.h"

@implementation MSActivityIndicatorTextModel

@synthesize title;
@synthesize hasActivityIndicator;
@synthesize isActivityIndicatorAnimating;
@synthesize viewClass;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"";
        self.viewClass = [MSActivityIndicatorTextStatusBar class];
        self.hasActivityIndicator = YES;
        self.isActivityIndicatorAnimating = YES;
    }
    
    return self;
}

- (UIView<MSStatusBarUpdating> *)statusBarWithData:(id<MSStatusBarModel>)data
{
    UIView<MSStatusBarUpdating> *view = [[self.viewClass alloc] initWithFrame:CGRectZero];
    
    return view;
}

@end
