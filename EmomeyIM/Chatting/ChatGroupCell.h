//
//  ChatGroupCell.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMassGroup.h"
typedef NS_ENUM(NSInteger, ChatCellBtnType)  {
    ChatCellBtnType_Edit  = 0,
    ChatCellBtnType_Send,
    ChatCellBtnType_More
};
@protocol ChatGroupCellDelegate <NSObject>
- (void)ChatGroupCelevent:(ChatCellBtnType)btnType userInfo:(CMassGroup *)userInfo;
@end

@interface ChatGroupCell : UITableViewCell
@property (nonatomic, assign) id <ChatGroupCellDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *memberList;
- (void)updateGroupCellMessage:(CMassGroup *)cellData;
+(CGFloat )ChatCroupHeight;
@end
