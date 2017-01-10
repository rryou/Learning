//
//  EMStatusBarData.m
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSStatusBarTextModel.h"
#import "MSTextStatusBar.h"

@implementation MSStatusBarTextModel

@synthesize title;
@synthesize viewClass;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"";
        self.viewClass = [MSTextStatusBar class];
    }
    
    return self;
}

- (UIView<MSStatusBarUpdating> *)statusBarWithData:(id<MSStatusBarModel>)data
{
    UIView<MSStatusBarUpdating> *view = [[self.viewClass alloc] initWithFrame:CGRectZero];
    
    
    
    return view;
}

@end
