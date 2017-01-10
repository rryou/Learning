//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "RoundAvatarView.h"
#import "ChattingMessageCell.h"
#import "UIButton+SocketImageCache.h"
#define OnLineW 16
#define OnLineH OnLineW

@interface RoundAvatarView ()
{
    UIButton *avatarBtn;
    BOOL shakeFlag;
    id parentCell;
}

@end

@implementation RoundAvatarView

@synthesize user = _user;
@synthesize avatarBtn;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    
    return self;
}

- (void)customInit{
    self.backgroundColor = [UIColor clearColor];
    avatarBtn = [[UIButton alloc] init];
    [self addSubview:avatarBtn];
    [avatarBtn addTarget:self action:@selector(actionPressed) forControlEvents:UIControlEventTouchUpInside];
    avatarBtn.backgroundColor = [UIColor clearColor];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    avatarBtn.frame = self.bounds;
    avatarBtn.layer.cornerRadius =avatarBtn.frame.size.width/2;
    avatarBtn.clipsToBounds = YES;
    avatarBtn.contentMode = UIViewContentModeScaleAspectFill;

}

- (void)actionPressed{
    if (_user){
    }
}

-(void)setUser:(UserInfo *)user{
    if (_user != user){
        _user = user;
    }
    NSString *tempStrName = [NSNumber numberWithLongLong:user.m_n64PortraitID].stringValue;
    [avatarBtn sk_setimageWith:tempStrName forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
    [avatarBtn sk_setimageWith:tempStrName forState:UIControlStateHighlighted placeholderImage:[UIImage imageNamed:@"normalcon"]];
}

- (void)changeOnlineStatus:(NSNotification *)notification{
    
}

-(id)getAvatarCell{
    id result = nil;
    id superview = [self superview];
    while (superview) {
        if([superview isKindOfClass:[ChattingMessageCell class]])
        {
            result = superview;
            break;
        }
        superview = [superview superview];
    }
    return result;
}

- (void)setIsOnline:(BOOL)theIsOnlin{
}

- (void)setTarget:(id)target selector:(SEL)selector
{
    [avatarBtn removeTarget:self action:@selector(actionPressed) forControlEvents:UIControlEventTouchUpInside];
    NSArray *actions = [avatarBtn actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    if (![actions containsObject:NSStringFromSelector(selector)]) {
        [avatarBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
