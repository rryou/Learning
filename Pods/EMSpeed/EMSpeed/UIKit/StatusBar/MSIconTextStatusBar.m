//
//  MSIconTextStatusBar.m
//  UI
//
//  Created by Samuel on 15/4/10.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//


#import "MSIconTextStatusBar.h"
#import "MSStatusBarIconTextModel.h"
#import <EMSpeed/MSUIKitCore.h>

@implementation MSIconTextStatusBar

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
        
        _imgvIcon = [[UIImageView alloc] init];
        [self addSubview:_imgvIcon];
    }
    
    return self;
}

- (void)updateStatusBar:(id<MSStatusBarModel>)model
{
    if ([model isKindOfClass:[MSStatusBarIconTextModel class]]) {
        MSStatusBarIconTextModel *data = model;
        
        _titleLabel.text = data.title;
        _imgvIcon.image = [UIImage imageNamed:data.iconName];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(2, CGRectGetHeight(self.frame)/2-_imgvIcon.image.size.height/2, _imgvIcon.image.size.width, _imgvIcon.image.size.height);
    _imgvIcon.frame = frame;
    
    frame = self.bounds;
    frame.origin.x = CGRectGetMaxX(_imgvIcon.frame) + 2;
    frame.size.width = self.bounds.size.width - frame.origin.x;
    _titleLabel.frame = frame;
}

@end

