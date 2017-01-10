//
//  ContractSecondCell.m
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/26.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ContractSecondCell.h"
#import "EMCommData.h"
#import "NSDate+Extends.h"

@interface ContractSecondCell(){
    
}
@property (nonatomic, strong) UILabel *namelb;
@end;

@implementation ContractSecondCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView = [[RoundAvatarView alloc] initWithFrame:CGRectMake(10, 15, 35, 35)];
        self.namelb = [[UILabel alloc] init];
        [self addSubview:self.iconView];
        [self addSubview:self.namelb];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.iconView setFrame:CGRectMake(10, 10, 35, 35)];
    [self.namelb setFrame:CGRectMake(60, 10,250, 35)];
    self.iconView.backgroundColor = [UIColor clearColor];
    self.namelb.backgroundColor = [UIColor clearColor];
    self.namelb.textColor = [UIColor blackColor];
    self.namelb.font = [UIFont systemFontOfSize:16];
}


- (void)upadteMemberInfo:(CGroupMember *)userInfo{
    if(self.userInfo!= userInfo){
       self.userInfo = userInfo;
       [self.iconView setUser:(UserInfo *)userInfo];
       self.namelb.text = [userInfo getNickName];
    }
}


+ (CGFloat )ContractSecondCellHeight{
    
    return 55;
}
@end

