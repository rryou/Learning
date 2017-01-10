//
//  tabPageView.m
//  EmomeyIM
//
//  Created by yourongrong on 16/10/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "TabPageView.h"
#import "PersonTabMessage.h"
#import <EMSpeed/MSUIKitCore.h>
#import "UIImage+Utility.h"
#define  KmargeX  10 
#define KmargeY 5
@interface TabPageView(){

}
@property (nonatomic, strong) UILabel *titleview;
@property (nonatomic, assign) CGFloat currentY;
@end

@implementation TabPageView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor  whiteColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}
//目前还未实现重用的机制，增加的view没有进行清理，目前是单独创建，没有进行复用
- (void)recreatetabView{
    if (self.pageMessage) {
        if (!self.titleview) {
            self.titleview = [[UILabel alloc] initWithFrame:CGRectMake(KmargeX, KmargeY, 250, 30)];
            [self addSubview:self.titleview];
            self.titleview.textAlignment = NSTextAlignmentLeft;
            self.titleview.textColor = RGB(56, 104, 193);
            self.titleview.font = [UIFont systemFontOfSize:16];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, 35, self.width - 10, 0.5)];
            lineView.backgroundColor = RGB(225, 225, 225);
            [self addSubview:lineView];
        }
        self.currentY = 36;
        self.titleview.text = self.pageMessage.name;
        for (int i= 0; i < self.pageMessage.pagelistarray.count ;i ++) {
            LabelMessage *tempLablist = [self.pageMessage.pagelistarray objectAtIndex:i];
            [self creaParttabView:tempLablist];
        }
        self.contentSize  = CGSizeMake(self.width, self.height>self.currentY + 4 *KmargeY?self.height:self.currentY + 6*KmargeY);
    }
}

- (void)creaParttabView:(LabelMessage *)tabsvalue{
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentY, self.width, 100)];
    tempView.backgroundColor = [UIColor clearColor];
    UILabel *tabnamelb = [[UILabel alloc] initWithFrame:CGRectMake(KmargeX, KmargeY, 250, 30)];
    tabnamelb.text = tabsvalue.name;
    tabnamelb.textColor  = [UIColor blackColor];
    tabnamelb.textAlignment = NSTextAlignmentLeft;
    tabnamelb.font = [UIFont systemFontOfSize:16];
    [tempView addSubview:tabnamelb];
    NSInteger  tabX = 0;
    NSInteger tabY=  37;
    NSInteger tabHeight = 70;
    
    for (int i = 0; i< tabsvalue.itemarry.count; i ++){
        NSString *tempStr = [tabsvalue.itemarry objectAtIndex:i];
        NSInteger tabLength = [self calutabWidt:tempStr];
        
        if (tabX + tabLength +  KmargeX *1.5 > self.width) {
            tabX = 0 ;
            tabY = tabY + 35;
            tabHeight = tabHeight + 33;
        }
        UIButton *tabButton = [self createBtn:CGRectMake(tabX + KmargeX *1.5, tabY + KmargeY, tabLength, 24) titleValue:tempStr];
        [tempView addSubview:tabButton];
        tabX = tabX + KmargeX *1.5 + tabLength;
    }
    
    [tempView setFrame:CGRectMake(0, self.currentY + KmargeY, self.width, tabHeight)];
    [self addSubview:tempView];
    self.currentY = self.currentY + tabHeight;
}

- (NSInteger )calutabWidt:(NSString *)tabStr{
    if (tabStr.length > 0) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],};
        CGSize textSize = [tabStr boundingRectWithSize:CGSizeMake(200, 30) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
        return KmargeX * 2 + textSize.width;
    }else{
        return 0;
    }
}

- (UIButton *)createBtn:(CGRect )frame titleValue:(NSString *)titleValue{
    UIButton *tempButton = [[UIButton alloc] initWithFrame:frame];
    [tempButton setTitle:titleValue forState:UIControlStateNormal];
    [tempButton setBackgroundImage:[UIImage ms_imageWithColor:RGB(215, 230, 256)] forState:UIControlStateNormal];
    [tempButton setBackgroundImage:[UIImage ms_imageWithColor:RGB(52, 94, 192)] forState:UIControlStateHighlighted];
    [tempButton setBackgroundImage:[UIImage ms_imageWithColor:RGB(52, 94, 192)] forState:UIControlStateSelected];
    [tempButton setTitleColor:RGB(159, 180, 230) forState:UIControlStateNormal];
    [tempButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [tempButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [tempButton setTintColor:RGB(157, 190, 243)];
    tempButton.layer.cornerRadius  = 3;
    tempButton.layer.masksToBounds = YES;
    tempButton.titleLabel.font = [UIFont systemFontOfSize:14];
    tempButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tempButton setTitle:titleValue forState:UIControlStateNormal];
    [tempButton addTarget:self action:@selector(btnClickevent:) forControlEvents:UIControlEventTouchUpInside];
    return tempButton;
}

- (void)btnClickevent:(UIButton *)sender{
    sender.selected = !sender.selected;
    if([self.tabBtndelegate respondsToSelector:@selector(tabPageUpdateMessage:isSelected:)]){
        [self.tabBtndelegate tabPageUpdateMessage:sender.titleLabel.text isSelected:sender.selected];
    }
}

- (NSString *)getSelectedvalue{
    NSArray *tempArray = [self allSubviews];
    NSMutableString *selectedTabValues = [NSMutableString string];
    for (int i= 0 ; i< tempArray.count; i ++) {
        UIView *tempView = [tempArray objectAtIndex:i];
        if ([tempView isKindOfClass:[UIButton class]]) {
            UIButton *btnview = (UIButton *)tempView;
            if (btnview.isSelected) {
                [selectedTabValues appendString:[NSString stringWithFormat:@" %@ |",btnview.titleLabel.text]];
            }
        }
    }
    if(selectedTabValues.length >0) {
        return selectedTabValues;
    }else{
        return nil;
    }
}

- (void)setSelectedValue:(NSString *)selectevalue{
    NSArray *tempArray = [self allSubviews];
    NSString *tagStringlist = [selectevalue  stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *tagList = [tagStringlist componentsSeparatedByString:@"|"];
    for (int i= 0 ; i< tempArray.count; i ++) {
        UIView *tempView = [tempArray objectAtIndex:i];
        if ([tempView isKindOfClass:[UIButton class]]) {
            UIButton *btnview = (UIButton *)tempView;
            if([tagList containsObject:btnview.titleLabel.text]){
                btnview.selected  =YES;
            }
        }
    }
}
@end
