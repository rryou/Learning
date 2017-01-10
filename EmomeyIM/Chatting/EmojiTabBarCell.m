//
//  EmojiTabBarCell.m
//  EmojProj
//
//  Created by ding xiuwei on 15/6/18.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import "EmojiTabBarCell.h"
#import "UIImageView+WebCache.h"
#import <EMSpeed/MSUIKitCore.h>
@interface EmojiTabBarCell ()
{
    UILabel *_nameLB;
    UIImageView *_imageView;
}

@end

@implementation EmojiTabBarCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        _nameLB = [[UILabel alloc] initWithFrame:self.bounds];
        _nameLB.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLB];
        _nameLB.backgroundColor = [UIColor clearColor];
        _nameLB.font = [UIFont systemFontOfSize:11];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 8, 2)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.hidden = YES;
        
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width -1, 0, 1, frame.size.height)];
        [self.contentView addSubview:line2];
        line2.backgroundColor = RGB(204, 210, 220);
        
        UIView *bgView = [[UIView alloc] init];
        self.backgroundView = bgView;
        bgView.backgroundColor = [UIColor clearColor];
        
        UIView *selectedView = [[UIView alloc] init];
        self.selectedBackgroundView = selectedView;
        selectedView.backgroundColor = RGB(204, 210, 220);
    }
    return self;
}

-(void)loadData:(EmojiTabType*)data
{
    _imageView.hidden = YES;
    _nameLB.hidden = YES;
    _imageView.image = nil;
    //以后实现
//    if (data.type == EmoTabType_static)
//    {
//        _nameLB.text = @"静态";
//        _nameLB.hidden = NO;
//    }
//    else if (data.type == EmoTabType_Recentuse)
//    {
//        _nameLB.text = @"常用";
//        _nameLB.hidden = NO;
//    }
}
@end
