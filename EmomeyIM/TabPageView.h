//
//  tabPageView.h
//  EmomeyIM
//
//  Created by yourongrong on 16/10/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonTabMessage;
@protocol TabPageViewdelegate <NSObject>
- (void)tabPageUpdateMessage:(NSString *)tabValue isSelected:(bool) selected;
@end

@interface TabPageView : UIScrollView
@property (nonatomic, strong) PersonTabMessage *pageMessage;
@property (nonatomic, assign) id <TabPageViewdelegate> tabBtndelegate;
- (NSString *)getSelectedvalue;
- (void)setSelectedValue:(NSString *)selectevalue;
- (void)recreatetabView;
@end
