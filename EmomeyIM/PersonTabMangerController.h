//
//  PersonTabMangerController.h
//  EmomeyIM
//
//  Created by yourongrong on 16/10/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonTabMessage.h"
#import "UserInfo.h"

@interface PersonTabMangerController : UIViewController
- (id) initWithMemberInfo:(CGroupMember *)memberInfro customerTag:(NSString *)tabStrs;
@end
