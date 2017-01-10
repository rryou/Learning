//
//  ChatGroupCell.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ChatGroupCell.h"
#import "RoundAvatarView.h"
#import "GroupIconView.h"
#import <EMSpeed/MSUIKitCore.h>
#import "EMCommData.h"
#import "UIImage+Utility.h"
@interface ChatGroupCell()<GroupIconViewDelegate>{
    
}
@property (nonatomic, strong) UILabel *namelb;
@property (nonatomic, strong) UIButton *editGroupBtn;
@property (nonatomic, strong) UIButton *sendGroupmessageBtn;
@property (nonatomic, strong) GroupIconView *groupIconView;
@property (nonatomic, strong) CMassGroup *massgroupdata;
@end

@implementation ChatGroupCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.namelb = [[UILabel alloc] init];
        self.namelb.font = [UIFont systemFontOfSize:18];
        self.namelb.textColor = [UIColor blackColor];
        [self addSubview:self.namelb];
        
        self.groupIconView = [[GroupIconView alloc] init];
        [self addSubview:self.groupIconView];
    
        self.editGroupBtn = [[UIButton alloc] init];
        [self addSubview:self.editGroupBtn];
        self.sendGroupmessageBtn = [[UIButton alloc] init];
        [self addSubview:self.sendGroupmessageBtn];
        
        [self.editGroupBtn setTitle:@"编辑群" forState:UIControlStateNormal];
        self.editGroupBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.editGroupBtn setTitleColor:RGB(64, 115, 200) forState:UIControlStateNormal];
        [self.editGroupBtn addTarget:self action:@selector(editGroupEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sendGroupmessageBtn setTitle:@"群发" forState:UIControlStateNormal];
        [self.sendGroupmessageBtn addTarget:self action:@selector(sendMessageEvent:) forControlEvents:UIControlEventTouchUpInside];
        self.sendGroupmessageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.editGroupBtn.layer.cornerRadius = 3;
        self.sendGroupmessageBtn.layer.cornerRadius = 3;
        [self.sendGroupmessageBtn.layer setMasksToBounds:YES];
        [self.editGroupBtn.layer setMasksToBounds:YES];
        [self.editGroupBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(238, 244, 255) ] forState:UIControlStateNormal];
        [self.sendGroupmessageBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(77, 121, 200) ] forState:UIControlStateNormal];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)editGroupEvent:(id)sender{
    if ([self.delegate respondsToSelector:@selector(ChatGroupCelevent:userInfo:)]) {
        [self.delegate ChatGroupCelevent:ChatCellBtnType_Edit  userInfo:self.massgroupdata];
    }
}

- (void)sendMessageEvent:(id)sender{
    if ([self.delegate respondsToSelector:@selector(ChatGroupCelevent:userInfo:)]) {
        [self.delegate ChatGroupCelevent:ChatCellBtnType_Send userInfo:self.massgroupdata];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.namelb setFrame: CGRectMake(20, 10,120 , 20)];
    [self.groupIconView setFrame:CGRectMake(10, 35, 185, 60)];
    [self.editGroupBtn setFrame: CGRectMake(self.frame.size.width - 140, 65, 60, 25)];
    [self.sendGroupmessageBtn setFrame:CGRectMake(self.frame.size.width - 70, 65, 50, 25)];
}

- (void)updateGroupCellMessage:(CMassGroup *)cellData{
    self.massgroupdata = cellData;
    if (cellData.m_aGroupID &&cellData.m_aGroupID.count > 0) {
        NSMutableArray *tempArray =[NSMutableArray array];
        for(int i = 0; i <cellData.m_aGroupID.count; i ++){
            NSNumber *tempnumber = [cellData.m_aGroupID objectAtIndex:i];
            CGroupMember *tempMember = [[EMCommData sharedEMCommData] getMemberByGroupId:tempnumber.longLongValue];
            if (tempMember) {
                [tempArray addObject:tempMember];
            }
        }
        [self.groupIconView removeFromSuperview];
        self.groupIconView = [[GroupIconView alloc] init];
//        self.groupIconView.delegate = self;
        [self addSubview:self.groupIconView];
        
        [self.groupIconView setGroupMemberList:tempArray];
        self.namelb.text = cellData.m_strName;
    }
}

- (void)GroupIconViewMoreEvent:(UIButton *)sender{
    if ( [self.delegate respondsToSelector:@selector(ChatGroupCelevent:userInfo:)]) {
        [self.delegate ChatGroupCelevent:ChatCellBtnType_More userInfo:self.massgroupdata];
    }
}

+(CGFloat )ChatCroupHeight{
    return 105;
}
@end
