//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentInfo.h"
#import "UserInfo.h"

typedef enum {
    ChattingContent_Invalid = -1,
    ChattingContent_Text = 0,
    ChattingContent_SpecialEmo,
    ChattingContent_Tip,
    ChattingContent_Image
} ChattingContentType;  //和ContentInfo.h 文件定义的 content type  对应

typedef enum {
    ChattingContentSource_Incoming,
    ChattingContentSource_Outgoing,
    ChattingContentSource_System
} ChattingContentSource;

@interface ChattingContent : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) UserInfo *sender; // sender = nil 被认为是tip
@property (nonatomic, strong) NSString *otherId;
@property (nonatomic, assign) ChattingContentType contentType;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) NSTimeInterval createTime; // 单位：毫秒
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int status; // 发送状态

- (NSArray *)attachments;
- (NSArray *)emoArray;
- (BOOL)supportForward;
- (BOOL)supportDelete;
- (BOOL)supportCopyText;
@end
