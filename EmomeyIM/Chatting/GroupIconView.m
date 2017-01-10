//
//  GroupIconView.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "GroupIconView.h"
#import <EMSpeed/MSUIKitCore.h>
#import "UIButton+SocketImageCache.h"
#define lefMarge 10
#define MargeWidth  15
@interface GroupIconView(){

}
@property (nonatomic, strong) NSMutableArray *memberlist;
@property (nonatomic, assign) GroupType currentShowType;
@property (nonatomic, strong) UIButton *moreBtn;
@end;


@implementation GroupIconView

- (id) init{
    self = [super init];
    if (self) {
        self.currentShowType = GroupType_little;
    }
    return self;
}

- (void)setShowTpy:(GroupType)showType{
    self.currentShowType = showType;
}

- (void)setGroupMemberList:(NSMutableArray *)memberlist{
    self.memberlist = [NSMutableArray arrayWithArray:memberlist];
    NSInteger maxSize= 3;
    NSInteger MargeSize = 5;
    CGFloat lefvalue = lefMarge;
    if (self.currentShowType == GroupType_More) {
        maxSize = 5;
        MargeSize = 15;
    }
    
    if (self.memberlist.count > 0) {
        for (int  i = 0; i < self.memberlist.count &&i <maxSize; i ++) {
            UIView *tempView =  [self createView: [memberlist  objectAtIndex:i] leftPoint:lefvalue];
            [tempView setFrame:CGRectMake(lefvalue, 2, 40, 55)];
            lefvalue = lefvalue + (35 + MargeSize);
            [self addSubview:tempView];
        }
    }
    if(self.currentShowType == GroupType_More ||self.memberlist.count >3){
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"moreIcon@2x.png"] forState:UIControlStateNormal];
        if (self.currentShowType ==GroupType_More) {
           [_moreBtn addTarget:self action:@selector(MoreEventclick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:_moreBtn];
    }else{
        if (_moreBtn) {
            [_moreBtn removeFromSuperview];
            _moreBtn = nil;
        }
    }
}

- (void)MoreEventclick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(GroupIconViewMoreEvent:)]) {
        [self.delegate GroupIconViewMoreEvent:sender];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if(_moreBtn){
        [_moreBtn setFrame:CGRectMake(self.width - 50 , 5,30 , 30)];
    }
}

- (UIView *)createView:(CGroupMember *)member leftPoint:(CGFloat) left{
    UIView *tempView = [[UIView alloc] init];
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, 30, 30)];
    NSString  *tempStrName = [NSNumber numberWithLongLong:member.m_n64PortraitID].stringValue;
    [iconView sk_setimageWith:tempStrName forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
//    iconView.layer.contents = (id)[UIImage imageNamed:[NSNumber numberWithLongLong:member.m_n64PortraitID].stringValue].CGImage;
    iconView.layer.cornerRadius = 15;
    [tempView addSubview:iconView];
    UILabel *namelb = [[UILabel alloc] initWithFrame:CGRectMake(2, 35, 35, 15)];
    namelb.text = [member getNickName];
    namelb.font = [UIFont systemFontOfSize:14];
    namelb.textAlignment = NSTextAlignmentCenter;
    namelb.lineBreakMode = NSLineBreakByTruncatingTail;
    namelb.textColor = RGB(51, 51, 51);
    [tempView addSubview:namelb];
    return tempView;
}@end
