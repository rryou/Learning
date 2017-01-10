//
//  GroupIconView.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
typedef NS_ENUM(NSInteger, GroupType)  {
    GroupType_little  = 0,
    GroupType_More
};

@protocol GroupIconViewDelegate <NSObject>
- (void) GroupIconViewMoreEvent:(UIButton *)sender;
@end
@interface GroupIconView : UIView
@property (nonatomic, assign) id <GroupIconViewDelegate> delegate;
- (void)setShowTpy:(GroupType)showType;
- (void)setGroupMemberList:(NSMutableArray *)memberList;
@end
