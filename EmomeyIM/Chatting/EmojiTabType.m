//
//  EmoTabType.m
//  LoochaCampusMain
//
//  Created by ding xiuwei on 15/6/26.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import "EmojiTabType.h"

@implementation EmojiTabType
- (instancetype)initWithType:(EmoTabType_emo)t withName:(NSString*)name withSrc:(NSURL*)src
{
    if (self = [super init])
    {
        _name = name;
        _type = t;
        _src = src;
    }
    return self;
}
@end
