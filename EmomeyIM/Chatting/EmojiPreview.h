//
//  EmojiPreview.h
//  LoochaCampusMain
//
//  Created by ding xiuwei on 15/6/24.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMEmo.h"
@interface EmojiPreview : UIView
@property(nonatomic,assign)int arowHight; //箭头的高
@property(nonatomic,assign)CGFloat arowOffsetX;//箭头偏移底部中心 x的坐标
@property(nonatomic,assign)CGFloat backGroudAlpha;
-(void)loadData:(DMEmo*)emo;

@end