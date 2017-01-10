//
//  EmojiTabarBar.h
//  EmojProj
//
//  Created by ding xiuwei on 15/6/18.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiTabType.h"
@protocol EmojiTabarBarDelegate <NSObject>

- (void)tapType:(NSInteger)num withType:(EmojiTabType*)type;

- (void)EmojiTabarBarAddEvent:(id)sender;

@end

@interface EmojiTabarBar : UIView
{
    id<EmojiTabarBarDelegate>delegate;
}

@property(nonatomic,weak)id<EmojiTabarBarDelegate>delegate;
@property(nonatomic,assign)NSInteger number;
- (instancetype)initWithFrame:(CGRect)frame withData:(NSArray*)arr;
- (void)scrollViewToNumber:(NSInteger)n;
- (void)setAddDynamicbtnDisable;
-(void)reloadData;

@end
