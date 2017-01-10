//
//  EMStatusBarLabel.m
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSTextStatusBar.h"
#import "MSStatusBarTextModel.h"
#import <EMSpeed/MSUIKitCore.h>

@interface MSTextStatusBar() {
}

@end

@implementation MSTextStatusBar

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, MSScreenWidth(), MSStatusBarHeight());
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.font = [UIFont systemFontOfSize:12];
        [self addSubview:label];
        _titleLabel = label;
    }
    
    return self;
}

- (void)updateStatusBar:(id<MSStatusBarModel>)model
{
    if ([model isKindOfClass:[MSStatusBarTextModel class]]) {
        MSStatusBarTextModel *data = (MSStatusBarTextModel *)model;
        _titleLabel.text = data.title;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
