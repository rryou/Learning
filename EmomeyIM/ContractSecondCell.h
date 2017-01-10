//
//  ContractSecondCell.h
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/26.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "RoundAvatarView.h"

@interface ContractSecondCell : UITableViewCell
@property (nonatomic, strong) RoundAvatarView *iconView;
@property (nonatomic, strong) CGroupMember *userInfo;
- (void)upadteMemberInfo:(CGroupMember *)userInfo;
+ (CGFloat )ContractSecondCellHeight;
@end
