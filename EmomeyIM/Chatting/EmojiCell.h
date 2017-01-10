//
//  EmojiCell.h
//  EmojProj
//
//  Created by ding xiuwei on 15/6/17.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiItemView.h"
@interface EmojiCell : UICollectionViewCell
-(void)loadData:(DMEmo*)emo;

@property(nonatomic,copy)void (^longPressCallBack)(UILongPressGestureRecognizer *g);
@end
