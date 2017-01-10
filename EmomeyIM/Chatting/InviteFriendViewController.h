//
//  InviteFriendViewController.h
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/26.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CGroupMember;
@protocol InviteFriendDelegate<NSObject>
@optional
-(void)confirmInviteFriend:(CGroupMember *)selectMember;
-(void)willPopController;

@end

@interface InviteFriendViewController : UIViewController
@property (nonatomic, assign) id<InviteFriendDelegate> delegate;

- (id)initWithExceptGroupid:(NSArray *)eexceptGroups;
@end
