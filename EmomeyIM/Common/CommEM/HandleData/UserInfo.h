//
//  UserInfo.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Buffer.h"
enum { TYPE_COUPLE = 1, TYPE_NORMAL, TYPE_SERVICE };
enum { MSG_TEXT = 1, MSG_FILE, MSG_PIC, MSG_NOTICE };
enum { FT_Portrait = 0, FT_File, FT_Pic};
typedef NS_ENUM(NSInteger, Mgs_Status_Value){
    MSG_STATUS_Sending = 100,
    MSG_STATUS_Success,
    MSG_STATUS_Delete,
    MSG_STATUS_Fail,
};

typedef  NS_ENUM(NSInteger, Mgs_Item_Value){
    MSG_ITEM_TEXT = 0,
    MSG_ITEM_ICON,
    MSG_ITEM_IMAGE,
    MSG_ITEM_FILE,
    MSG_ITEM_URL
};
@class EMFileID;
@interface CMsgItem : NSObject
@property (nonatomic, assign) Byte m_cType;
@property (nonatomic, strong) NSString *m_strItem;
@property (nonatomic, assign) int64_t m_n64FileID;
@property (nonatomic, assign) int32_t m_dwFileSize;
@property (nonatomic, strong) EMFileID *m_pFileID;//文件
- (void)createMsgItem:(Byte )ctype int64:(int64_t)fileId strItem:(NSString *)strItem;
- (NSString *)getPathName;
- (NSString *)getFileName;
@end


@interface UserInfo : NSObject
@property (nonatomic, assign) int64_t m_n64AccountID;
@property (nonatomic, assign) int64_t m_n64PortraitID;
@property (nonatomic, strong) NSString *m_strNickName;
@property (nonatomic, strong) NSString *m_strSignature;
@property (nonatomic, strong) NSString *m_strUserName;
@property (nonatomic, strong) NSString *m_strPassword;
@property (nonatomic, assign) NSInteger m_nPlatformID;
@property (nonatomic, assign) int64_t m_nGroupId;
-(void)read:(CBuffer &)buffer version:(short)wVersion;
- (void)write:(CBuffer &)buffer version:(short)wVersion;
+ (NSInteger)compareUserInfo:(UserInfo &)first secondUser:(UserInfo &)second;
@end

@interface CGroupMember : NSObject
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64PortraitID;
@property (nonatomic, strong) NSString *m_strNickName;
@property (nonatomic, strong) NSString *m_strMbrNickName;
@property (nonatomic, assign) int32_t m_dwPermissionFlag ;
@property (nonatomic, strong) NSString *m_strTag;
@property (nonatomic, strong) NSString *m_strEM_UserName;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, strong) NSString *contractName;
@property (nonatomic, strong) NSString *Gm_strPeerRemark;
@property (nonatomic, strong) NSString *searchName;
- (NSString *)getNickName;
- (NSString *)getTagGroupName;

- (NSString *)getSigleName;
@end
@class CMsgItem;
@class CGroup;
@interface CNewMsg:NSObject
@property (nonatomic, strong) CGroup* m_pGroup;
@property (nonatomic, assign) int64_t m_n64MsgID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64GrpMsgID;
@property (nonatomic, assign) int64_t m_dwMsgSeconds;
@property (nonatomic, assign) int64_t m_n64SenderID;
@property (nonatomic, assign) int64_t m_n64DeleterID;
@property (nonatomic, assign) int32_t m_dwExprSeconds;
@property (nonatomic, assign) short  m_sMsgType;
@property (nonatomic, strong) NSString *m_strMsgText;
@property (nonatomic, strong) NSMutableArray <CMsgItem *> *m_aItem;// CMsgItem
@property (nonatomic, strong) EMFileID *m_pFileID;
@property (nonatomic, assign) Mgs_Status_Value msg_Status;
- (int64_t) getSortID;

- (void)readFile:(CBuffer &)buffer version:(short )wVersion;
- (void)writeFile:(CBuffer &)buffer version:(short )wVersion;
- (bool)wantShow;
- (void)CheckFileID;
- (void)AfterRecv;
- (NSString *)GetShow:(bool) bWantWR;
- (NSString *)Item2Text;
- (int)Text2Item:(NSString *)strText;
- (NSString *)Item2Show;
@end

@interface CGroupBase:NSObject
@property (nonatomic, assign) int64_t m_n64AccountID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64PortraitID;
@property (nonatomic, assign) short m_wGroupType;  // =1联系人(1对1)，=2多人群，3=客服群
@property (nonatomic, assign) int32_t m_dwPermissionFlag;
// 群权限,位,	0x01=可以获得其他用户帐户，否则只能看到能发言的老师;	0x02=可以发言;	0x04=可以发文件	0x08=服务群;	0x10=群主;	0x800000=群置顶
@property (nonatomic, assign) int64_t m_n64Peer_MinMsgID;  // m_wGroupType=1:对方的账号ID m_wGroupType=2|3:加入群时的消息号
@property (nonatomic, assign) int64_t m_n64MaxGrpMsgID;
@property (nonatomic, assign) int32_t m_dwMaxMsgSeconds;
@property (nonatomic, strong) NSString *m_strPeerGrpName;  	// m_wGroupType=1:对方的EM号 m_wGroupType=2|3：群名称
@property (nonatomic, assign) NSString *m_strNickName;     // m_wGroupType=1:对方的昵称 m_wGroupType=2|3：无效
@property (nonatomic, strong) NSString *m_strPeerRemark;   // m_wGroupType=1:对方的备注 或 m_wGroupType=2群备注 或 m_wGroupType=3客户备注 (你写的)
@property (nonatomic, assign) int64_t m_n64ReadGrpMsgID;   // 已读计数, 已读的最大GrpMsgID
@property (nonatomic, strong) NSString *m_strSignature;	   // m_wGroupType=1:对方写的个性化签名
@property (nonatomic, assign) int32_t m_nNumGrpMember ;     // =2 | 3:群成员个数
@property (nonatomic, strong) NSString *m_strCustomerTag;  // 客户标签，m_wGroupType=3有用，==CGoupMember里的m_strTag，在登录的时候在GroupMember里下发，有改变是有Cmd
- (Byte )isTopMost;
- (void)setTopMost:(Byte )cTopMost;
- (bool)isService;
- (bool)isLord;
- (bool)isAdmin;
- (bool)canSend;
- (bool)canSendFile;
@end

@interface CRecvGroupMember:NSObject
@property (nonatomic, assign) int64_t m_n64AccountID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) Byte m_cSelf;
@property (nonatomic, strong) CGroupMember *m_Member;
@end

@interface CGroup: CGroupBase
@property (nonatomic, strong) NSMutableArray <CNewMsg * > *m_aMsg;
//CMsgItemArray m_aItemUpload;		//正在上传的文件
@property (nonatomic, strong) NSMutableArray <CGroupMember *> *m_aMember;
@property (nonatomic, strong) NSMutableArray <CGroupMember *> *m_aMemberS;
@property (nonatomic, assign) int64_t m_n64MaxMsgID; // m_aMsg里最大的m_n64MsgID, 显示的时候排序用
@property (nonatomic, assign) int32_t m_dwUpdateCount;
@property (nonatomic, assign) int64_t m_n64LoginGrpMsgID;// Login的时候返回的最大的m_n64MaxGrpMsgID，的处理要用到
@property (nonatomic, assign) bool m_bLoaded;
@property (nonatomic, assign) bool m_bWantSave;
@property (nonatomic, assign) bool m_bQueryMemberDone; // TRUE==已经发送过CIM_QueryMemberData
@property (nonatomic, assign) BOOL m_MutilpGroup;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, assign) NSInteger unReadCount;
- (void)setGroupMessage:(CGroupBase *)baseGroup;

- (void)Read;
- (void)Write;
- (CNewMsg *)createMsg:(int64_t) n64GrpMsgID;
- (CNewMsg *)getMsg:(int64_t) n64GrpMsgID;
- (void)DelMsg:(int64_t)n64GrpMsgID deleid:(int64_t )n64DelID;
- (bool)updateMessage:(CNewMsg *)pMsg addcount:(bool) addCount;
- (void)queryMsg;

- (CGroupMember *)findMember:(int64_t) n64UserID;
- (CGroupMember *)getCustomerInfo;
- (bool )findMember:(int64_t) n64UserID portraitid:(int64_t &)n64PortraitID strNickName:(NSString *)strNickName bgrpNickName:(bool )bGrpNickName bWantWR:(bool)bWantWR;

- (void)getShowNameID:(int64_t)n64ShowID strName1:(NSString *)strName1 strName2:(NSString *)strName2;

- (NSString *)GetTag;
- (NSString *)getTagNickName;
- (NSString *)GetEM_UserName;

- (bool)ModGrpNickName:(int64_t)n64UserID strGrpNickName:(NSString *)strGrpNickName;

- (void)SendModPortrait:(int64_t)n64UserID GroupID:(int64_t) n64GroupID NewPortraitID:(int64_t ) n64NewPortraitID strNewPortraitFile:(NSString *)strNewPortraitFile;

- (NSString *)GetLastMsgShow;

@end
@interface CGroupSort : NSObject
@property (nonatomic, strong) CGroup* m_pGroup;
@end

@interface CQueryMsg : NSObject
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64MaxMsgID;
@property (nonatomic, assign) int64_t m_n64RecvMsgID;
+(NSInteger) compareCQueryMsg:(CQueryMsg *)first secondMsg:(CQueryMsg *)second;
@end

@interface CChatCmd : NSObject
@property (nonatomic, assign) int64_t m_n64CmdID;
@property (nonatomic, assign) int64_t m_dwSeconds;
@property (nonatomic, assign) short m_wType;
@property (nonatomic, strong) NSData *m_Data;
- (void)clearData;
- (void)doCmd;
- (int64_t) getSortid;
@end
