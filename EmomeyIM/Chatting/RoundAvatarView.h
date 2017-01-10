//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "UserInfo.h"
@interface RoundAvatarView : UIView

@property (nonatomic, retain) UserInfo *user;
@property (nonatomic, readonly) UIButton *avatarBtn;
- (void)setIsOnline:(BOOL)theIsOnline;
- (void)setTarget:(id)target selector:(SEL)selector;
@end
