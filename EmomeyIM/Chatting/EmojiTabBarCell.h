//
//  EmojiTabBarCell.h
//  EmojProj
//
//  Created by ding xiuwei on 15/6/18.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiTabType.h"
@interface EmojiTabBarCell : UICollectionViewCell
-(void)loadData:(EmojiTabType *)type;

@end
