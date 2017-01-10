//
//  EmoTabType.h
//  LoochaCampusMain
//
//  Created by ding xiuwei on 15/6/26.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EmoTabType_Recentuse,//最近使用
    EmoTabType_static, //静态
} EmoTabType_emo;


@interface EmojiTabType : NSObject
@property(nonatomic,assign) EmoTabType_emo type;
@property(nonatomic,copy)   NSString *name;
@property(nonatomic,copy)   NSURL *src;

- (instancetype)initWithType:(EmoTabType_emo)t withName:(NSString*)name withSrc:(NSURL*)src;
@end