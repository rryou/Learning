//
//  ContractCell.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//
#import "NSDate+Extends.h"
#import "ContractCell.h"
#import "EMCommData.h"
#import "TTLoochaStyledTextLabel.h"
#import "TTLoochaStyledText.h"
#import <EMSpeed/MSUIKitCore.h>
@interface ContractCell(){
    
}
@property (nonatomic, strong) UILabel *namelb;
@property (nonatomic, strong) TTLoochaStyledTextLabel *chattingvaluelb;
@property (nonatomic, strong) UILabel *timevaluelb;
@property (nonatomic, strong) UILabel *unReadCountlb;
@property (nonatomic, strong) UIButton *selectedView;
@property (nonatomic, assign) bool showSelected;
@property (nonatomic, assign) bool currentSelectedValue;
@property (nonatomic, assign) BOOL isMutilGroup;
@property (nonatomic, strong) UIView *mutlIcon;
@property (nonatomic, assign) CGFloat maxlableSize;
@property (nonatomic, assign) CGFloat maxunReadSize;
@property (nonatomic, assign) NSInteger unReadMessageCount;
@end;

@implementation ContractCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView = [[RoundAvatarView alloc] initWithFrame:CGRectMake(10, 15, 35, 35)];
        self.namelb = [[UILabel alloc] init];
        self.chattingvaluelb = [[TTLoochaStyledTextLabel alloc] init];
        self.chattingvaluelb.maxnumOfLines = 1;
        self.timevaluelb = [[UILabel alloc] init];
        self.timevaluelb.textAlignment = NSTextAlignmentRight;
        self.unReadCountlb  =[[UILabel alloc] init];
        self.unReadCountlb.textAlignment = NSTextAlignmentCenter;
        self.unReadCountlb.font = [UIFont systemFontOfSize:14];
        self.unReadCountlb.backgroundColor = RGB(105, 163, 246);
        self.unReadCountlb.textColor = [UIColor whiteColor];
        self.unReadCountlb.layer.cornerRadius = 10;
        self.unReadCountlb.layer.masksToBounds = YES;
        
        [self addSubview:self.iconView];
        [self addSubview:self.namelb];
        [self addSubview:self.chattingvaluelb];
        [self addSubview:self.timevaluelb];
        [self addSubview:self.unReadCountlb];
        self.selectedView = [[UIButton alloc] init];
        [self.selectedView addTarget:self action:@selector(selectedEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.selectedView setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
        [self.selectedView setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        self.mutlIcon = [[UIView alloc] init];
        self.mutlIcon.hidden =YES;
        self.mutlIcon.layer.contents = id([UIImage imageNamed:@"MutilGroup"].CGImage);
        [self addSubview:self.mutlIcon];
        [self addSubview:self.selectedView];
        self.showSelectedView = NO;
        self.currentSelectedValue = NO;
        self.maxlableSize =150;
        self.maxunReadSize = 15;
    }
    return self;
}

- (void)selectedEvent:(id)sender{
    self.currentSelectedValue = !self.currentSelectedValue;
    self.selectedView.selected = self.currentSelectedValue;
    if ([self.delegate respondsToSelector:@selector(contractCellupdata:userInfo:)]){
        [self.delegate contractCellupdata:self.currentSelectedValue userInfo:self.userInfo];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.iconView setFrame:CGRectMake(10, 15, 35, 35)];
    [self.namelb setFrame:CGRectMake(60, 15, self.maxlableSize, 20)];
    [self.mutlIcon setFrame:CGRectMake(self.namelb.frame.size.width + self.namelb.frame.origin.x +10, self.namelb.frame.origin.y+2, 22, 15)];
    [self.chattingvaluelb setFrame:CGRectMake(60, 40, 150, 20)];
    [self.timevaluelb  setFrame:CGRectMake(self.frame.size.width - 90, 15, 80, 20)];
    [self.unReadCountlb setFrame:CGRectMake(self.frame.size.width - 10- self.maxunReadSize, 40, self.maxunReadSize, 20)];
    
    [self.selectedView setFrame:CGRectMake(self.frame.size.width -55,20 , 30, 30)];
    if (self.showSelected) {
        self.timevaluelb.hidden =YES;
        self.selectedView.hidden =NO;
    }else{
        self.timevaluelb.hidden =NO;
        self.selectedView.hidden =YES;
    }
    self.iconView.backgroundColor = [UIColor clearColor];
    self.namelb.backgroundColor = [UIColor clearColor];
    self.chattingvaluelb.backgroundColor = [UIColor clearColor];
    self.timevaluelb.backgroundColor = [UIColor clearColor];
    self.namelb.textColor = [UIColor blackColor];
    self.chattingvaluelb.textColor  = [UIColor grayColor];
    self.timevaluelb.textColor = [UIColor grayColor];
    self.namelb.font = [UIFont systemFontOfSize:15];
    self.chattingvaluelb.font = [UIFont systemFontOfSize:14];
    self.timevaluelb.font = [UIFont systemFontOfSize:13];
}

- (void)setShowSelectedView:(bool)showselected{
    self.showSelected = showselected;
    [self setNeedsLayout];
}

- (void)setselectedActive:(bool)hasselected{
    self.currentSelectedValue = hasselected;
    self.selectedView.selected = self.currentSelectedValue;
}

- (bool)getCurrentSelectedState{
    return self.currentSelectedValue;
}

- (NSString *)convertTimeStr:(int32_t) exprSecond{
     NSString *timeStr =[[NSDate dateWithTimeIntervalSince1970:exprSecond] prettyDateWithReference:[NSDate date]];
    return timeStr;
}

- (void)upadteMemberInfo:(CGroupMember *)userInfo{
    self.userInfo = userInfo;
    [self.iconView setUser:(UserInfo *)userInfo];
    self.namelb.text = [userInfo getNickName];
    CGSize textSize =[self.namelb.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]}];
    if (textSize.width<150) {
        self.maxlableSize = textSize.width;
    }else{
        self.maxlableSize = 150;
    }
    
    NSArray *tempMessagearray = [[EMCommData sharedEMCommData] getLimitMessagsByGroupId:userInfo.m_n64GroupID maxCount:1];
    if (tempMessagearray && tempMessagearray.count == 1) {
         CNewMsg *lastMessage = [tempMessagearray objectAtIndex:0];
        self.chattingvaluelb.contentStr =lastMessage.m_strMsgText;
        self.chattingvaluelb.text = [TTLoochaStyledText textFromLoochaText:lastMessage.m_strMsgText lineBreaks:YES URLs:YES isMeIPusblish:NO withGiftArr:nil];
        self.chattingvaluelb.backgroundColor = [UIColor clearColor];
        self.chattingvaluelb.textColor = [UIColor blackColor];
        self.chattingvaluelb.font = [UIFont systemFontOfSize:TTStyledTextFont];
        self.timevaluelb.text =[[NSDate dateWithTimeInterval:lastMessage.m_dwMsgSeconds  sinceDate:[[EMCommData sharedEMCommData] commonSinceDate]] prettyDateWithReference:[NSDate date]];
    }
    if (self.unReadMessageCount > 0) {
        if(self.unReadMessageCount >99){
            self.unReadCountlb.text =@"99+";
            self.maxunReadSize = 34;
            
        }else{
           self.unReadCountlb.text = [NSNumber numberWithLong:self.unReadMessageCount].stringValue;
            if (self.unReadCountlb.text.length ==1) {
                self.maxunReadSize = 20;
            }else{
                self.maxunReadSize =28;
            }
        }


        self.unReadCountlb.hidden = NO;
    }else{
        self.unReadCountlb.hidden = YES;
    }
    
    if (self.isMutilGroup) {
        self.mutlIcon.hidden = NO;
    }else{
        self.mutlIcon.hidden =YES;
    }
    self.showSelectedView = NO;
    self.currentSelectedValue = NO;
    if (self.currentSelectedValue) {
        [self.selectedView setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    }else{
        [self.selectedView setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    }
}

- (void)updateCGropInfo:(CGroup *)groupInfo{
    self.isMutilGroup = groupInfo.m_MutilpGroup;
    self.unReadMessageCount = groupInfo.unReadCount;
    [self upadteMemberInfo:[groupInfo getCustomerInfo]];
//    [groupInfo.m_aMember objectAtIndex:0]
}


+ (CGFloat )ContractCellHeight{
    
    return 70;
}
@end
