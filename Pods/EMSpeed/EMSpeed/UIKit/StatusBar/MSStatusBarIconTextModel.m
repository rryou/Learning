//
//  MSIconTextStatusBarData.m
//  UI
//
//  Created by Samuel on 15/4/10.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSStatusBarIconTextModel.h"
#import "MSIconTextStatusBar.h"

@implementation MSStatusBarIconTextModel

@synthesize title;
@synthesize iconName;
@synthesize viewClass;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"";
        self.viewClass = [MSIconTextStatusBar class];
    }
    
    return self;
}

- (UIView<MSStatusBarUpdating> *)statusBarWithData:(id<MSStatusBarModel>)data
{
    UIView<MSStatusBarUpdating> *view = [[self.viewClass alloc] initWithFrame:CGRectZero];
    
    return view;
}


@end
