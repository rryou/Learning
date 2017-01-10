//
//  ChatContentView.h
//  LoochaCampusMain
//
//  Created by 陈易侗 on 15/4/20.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChattingCellContext.h"

extern const CGFloat titleHeight;
extern const CGFloat imageDefaultHeight;

@protocol ChatContentViewDelegate <NSObject>

- (void)actionToDespiseTaWithId:(NSString *)message;

- (void)actionToRunOtherAppWith:(NSInteger)index;

@end

@class ChattingContent;

typedef enum : NSUInteger {
    ChatContentType_Text,           // 文本
    ChatContentType_Attachment,     // 图片、视频、语音、音乐
    ChatContentType_Photo_Check     // 照片审核
} ChatContentType;

@interface ChatContentView : UIView <ReusableViewProtocol>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) id<ChatContentViewDelegate> delegate;
@property (nonatomic, assign) NSInteger index;

- (void)updateWithContent:(ChattingContent *)content
                messageID:(NSString *)messageID
             withMaxWidth:(int)maxWidth;


+ (CGSize)viewSizeWithContent:(id)content maxWidth:(CGFloat)maxWidth;

@end
