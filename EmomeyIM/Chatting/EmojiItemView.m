//
//  EmojiItemView.m
//  EmojProj
//
//  Created by ding xiuwei on 15/6/16.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import "EmojiItemView.h"
#import "DMEmo.h"
#import "UIImageView+WebCache.h"
@interface EmojiItemView ()
{
    UIImageView *_emoView;
    UILabel *_nameLB;
}
@end

@implementation EmojiItemView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _emoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,frame.size.width, frame.size.width)];
        _emoView.backgroundColor = [UIColor clearColor];
        _emoView.userInteractionEnabled = YES;
        [self addSubview:_emoView];
        
        _nameLB = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width)];
        [self addSubview:_nameLB];
        _nameLB.backgroundColor = [UIColor clearColor];
        _nameLB.textAlignment = NSTextAlignmentCenter;
        _nameLB.font = [UIFont systemFontOfSize:10];
    }
    return self;
}

-(void)loadData:(DMEmo*)emo
{

    if (ItemShowTypeFixCount == emo.layoutAttribute.type)
    {
        _emoView.frame = CGRectMake(0, 0,self.frame.size.width, self.frame.size.width);
        _nameLB.frame =  CGRectMake(0, self.frame.size.width, self.frame.size.width, self.frame.size.height - self.frame.size.width);
        _nameLB.text = emo.name;
        _emoView.alpha = 1;
        _nameLB.alpha = 1;
    }
    else if (ItemShowTypeFlow == emo.layoutAttribute.type)
    {
        _emoView.frame = CGRectMake(0, 0,self.frame.size.width, self.frame.size.width);
        _nameLB.alpha = 0;
        _emoView.alpha = 1;
    }

    _emoView.image = nil;
    
    if (emo.type == LocalEmoTypeNormal)
    {
        _emoView.image = [UIImage imageNamed:emo.src];
    }
}

@end
