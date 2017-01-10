//
//  ContractCell.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "RoundAvatarView.h"
@protocol ContractCellDelegate <NSObject>
- (void)contractCellupdata:(bool)selected userInfo:(CGroupMember *)userInfo;
@end
@interface ContractCell : UITableViewCell
@property (nonatomic, strong) RoundAvatarView *iconView;
@property (nonatomic, assign) id<ContractCellDelegate> delegate;
@property (nonatomic, strong) CGroupMember *userInfo;
- (bool)getCurrentSelectedState;
- (void)upadteMemberInfo:(CGroupMember *)userInfo;
- (void)updateCGropInfo:(CGroup *)groupInfo;
- (void)setShowSelectedView:(bool)showselected;
- (void)setselectedActive:(bool)hasselected;
+ (CGFloat )ContractCellHeight;
@end
