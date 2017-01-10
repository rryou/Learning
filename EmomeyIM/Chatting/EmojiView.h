//
//  EmojiView.h
//  LoochaCampusMain
//
//  Created by ding xiuwei on 15/6/23.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmojiView;
@class DMEmo;
@protocol EmojiViewDelegate <NSObject>
- (void)emojiView:(EmojiView*)emojiView didSelecte:(DMEmo*)emo;
@end

@interface EmojiView : UIView
{
    id<EmojiViewDelegate>delegate;
}
@property(nonatomic,assign)id<EmojiViewDelegate>delegate;

- (void)disabledByDynamicEmojis;
+ (CGFloat)viewHeight;
@end
