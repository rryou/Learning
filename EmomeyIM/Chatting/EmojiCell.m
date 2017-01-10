//
//  EmojiCell.m
//  EmojProj
//
//  Created by ding xiuwei on 15/6/17.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import "EmojiCell.h"
#import "EmojiItemView.h"
#import "DMEmo.h"
#import <PureLayout.h>
#import <EMSpeed/MSUIKitCore.h>
@implementation EmojiCell
{
    EmojiItemView *_emoView;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _emoView = [[EmojiItemView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 24/2, self.frame.size.height/2 - 24/2 , 24 ,24)];
        [self.contentView addSubview:_emoView];
        UIView *backgroudView = [[UIView alloc]initWithFrame:self.bounds];
        backgroudView.backgroundColor =  RGB(201, 210, 220) ;
        //RCColorWithValue(0xccd2dc);
        [self setSelectedBackgroundView:backgroudView];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureHandle:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

-(void)loadData:(DMEmo*)emo
{
       _emoView.frame = CGRectMake(self.width/2 - 20/2, self.height/2 - 20/2 , 20 ,20);
    [_emoView loadData:emo];
}

- (void)longGestureHandle:(UILongPressGestureRecognizer*)g
{
    if (_longPressCallBack)
    {
        _longPressCallBack(g);

    }
}
@end
