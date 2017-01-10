//
//  EMCommData.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/2.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "EMFileData.h"
@class CMassGroup;
@interface EMCommData : NSObject{
    Byte *xorTable;
    int32_t xtableSize;
    Byte *puserKey;
    int bBits;
    Byte *pcounter;
}
#define NOTIFIMESSAGEUPDATEMESSAGE @"noticeMessageUpdate"
@property (nonatomic, strong) UserInfo *selfUserInfo;
+(EMCommData*) sharedEMCommData;
- (NSDate *)commonSinceDate;
- (void)updateGroupUnReadCount:(int64_t)grouid;
- (void)reSetGroupUnReadCount:(int64_t)grouid;
- (void)setAccountLoginStatus:(BOOL) login;
- (void)clearAlldata;
- (bool)setMassGroup:(NSMutableArray *)massGrouparray;
- (void)updateMassGroup:(CMassGroup *)massGroup;
- (void)deleteMassGroup:(int64_t )massGroupId;
- (void)updateGroup:(CGroup *)massGroup;

- (void)updateMemberInfo:(CGroupMember *)newMember;
- (NSArray *)getMassGroup;

- (CGroupMember *)getMemberByGroupId:(int64_t )grouid;

- (Byte *)getAescounter;

- (CGroup *)getGroupbyid:(NSInteger) groupid;

- (CNewMsg *)getMsgbyId:(NSInteger) messageID;

- (void)addNewMsg:(CNewMsg *)newMessage needNotice:(bool)needNotice;

- (void)addQuerMsg:(CQueryMsg *)newMessage;

- (NSArray *)getSortGroup;

- (NSArray *)getGroupMember;

- (NSArray *)getMembersEecept:(NSArray *)exceptedGroupid;

- (NSArray *)getMessagelist;

- (NSArray *)getQuerayMsg;

- (NSArray *)getMessageListByGroupId:(int64_t) n_GroupID;

- (NSArray *)getLimitMessagsByGroupId:(int64_t) n_GroupId maxCount:(NSInteger )maxcount;

- (NSArray *)getNewMessageListByGroupId:(int64_t) n_GroupID afterMsgid:(int64_t)maxMsgid;
- (NSArray *)getMoreMessageListByGroupId:(int64_t) n_GroupID beforeMsgid:(int64_t)maxMsgid;
- (NSArray *)getMoreLimitMessageListByGroupId:(int64_t) n_GroupID beforeMsgid:(int64_t)maxMsgid limitedNumber:(NSInteger )maxNumber;
- (void)addNewGroup:(CGroup *)newGroup;

- (void)addNewMember:(CGroupMember  *)newMember;
- (void)setGroupMe:(NSArray<CRecvGroupMember *> *)aMember;
- (bool) haveServiceGroup;

- (NSArray *)getTabGroups:(NSArray *)tabArray;

- (bool)haveSendGroup:(int64_t )n64GroupID;

- (bool)haveSendFileGroup:(int64_t)n64GroupID;

- (NSDictionary *)getemojiDict;

- (bool) isLogined;

- (int64_t)getUserId;

- (NSArray *)getGroupList;

- (void)setUserInfo:(UserInfo *)userInfo;
- (void)addUserFileData:(EMFileData *)fileData;

- (EMFileData *)getFileDataMessage;

- (EMFileID *)addFileid:(Byte)fileType n64FileId:(int64_t ) n64FileId strFileName:(NSString *)strFileName mData:(EMFileData *)m_data boverWrite:(bool) boverWrirte;

- (EMFileID *)getFileid:(Byte)fileType n64FileId:(int64_t) n64FileId n64GroupID:(int64_t) n64GroupId bRead:(bool)bRead;

- (bool) addfileId:(EMFileID *)pfileID;

- (NSString *)commFilePath;
- (int64_t)hashID:(Byte)cFileType pcHash:(Byte *)pcHash;
- (void)addHash2ID:(Byte) cFileType hash2id:(EMHash2ID *)hashId;
- (int64_t)getFileId:(Byte) cFileType;
- (bool)filehasload:(CMsgItem *)fileValue;
- (bool)imagehasload:(NSString *)fileId;
- (UIImage *)getlocalFile:(CMsgItem *)fileValue;
- (UIImage *)getlocalImage:(NSString *)fileId;
@end
