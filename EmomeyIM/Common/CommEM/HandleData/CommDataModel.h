//
//  CommDataModel.h
//  EmomeyIM
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "HandleDataModel.h"
#import "UserInfo.h"
#import "CMassGroup.h"
//#import "CGroupMemberRL.h"
#import "EMFileData.h"
@interface CIMLB_LoginData : HandleDataModel
@end
//////////////////////////////////////////////////////////////////////
@interface CCheckData : HandleDataModel

@end
//////////////////////////////////////////////////////////////////////
@interface CCheckAckData: HandleDataModel

@end
//////////////////////////////////////////////////////////////////////
@interface UserObject : NSObject
@property (nonatomic, assign) int64_t m_n64AccountID;
@property (nonatomic, assign) int64_t m_n64PortraitID;
@property (nonatomic, strong) NSString *m_strNickName;
@property (nonatomic, strong) NSString *m_strSignature;
@property (nonatomic, strong) NSString *m_strUserName;
@property (nonatomic, strong) NSString *m_strPassword;
@property (nonatomic, assign) NSInteger m_nPlatformID;
@end
//////////////////////////////////////////////////////////////////////
@interface CIM_LoginData : CCompressSockData
@property (nonatomic, assign) int32_t m_nPlatformID;
@property (nonatomic, strong) NSString *m_strName;
@property (nonatomic, strong) NSString *m_strPassword;
@property (nonatomic, assign) BOOL islogin;
@end
//////////////////////////////////////////////////////////////////////
@interface CIM_NewsMsgData : CCompressSockData
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64SenderID;
@property (nonatomic, assign) int32_t m_dwExprSeconds;
@property (nonatomic, assign) short m_sMsgType;
@property (nonatomic, strong) NSString *m_strMsgText;
@property (nonatomic, assign) int64_t m_n64MsgID;
@property (nonatomic, assign) int64_t m_n64GrpMsgID;
@property (nonatomic, assign) int32_t m_dwMsgSeconds;
- (void)CIM_NewsMsgData;
@end
//////////////////////////////////////////////////////////////////////
@interface CIM_MsgData :CCompressSockData
@property (nonatomic, assign) int64_t m_n64SenderID;
@property (nonatomic, assign) int32_t m_dwExprSeconds;
@property (nonatomic, strong) CNewMsg  *m_msg;
@property (nonatomic, assign) Byte m_cType; // 0==m_n64GroupID==单群；1==m_aGroupID==群发；2==m_n64BatGroupID==群组
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, strong) NSMutableArray *m_aGroupID;
@property (nonatomic, assign) int64_t m_n64BatGroupID;
@property (nonatomic, assign) int64_t m_n64MsgID;
@property (nonatomic, assign) int64_t m_n64GrpMsgID;
@property (nonatomic, assign) int32_t m_dwMsgSeconds;
@property (nonatomic, assign) NSInteger m_nPosUpload;
@property (nonatomic, strong) EMFileID *m_pFileID;
@property (nonatomic, assign) Byte m_cFileType;
@property (nonatomic, strong) NSString *m_strFileName;
@property (nonatomic, assign) int32_t m_dwTotalSize;
@property (nonatomic, assign) int32_t m_dwTotalPos;
@property (nonatomic, assign) BOOL m_bAnalysis;
@property (nonatomic, assign) int32_t m_dwSendPos;
@property (nonatomic, assign) int32_t m_dwTickCount;
- (CIM_MsgData *)clone;
- (void)analysis;
- (void)finishFileID;
@end
//////////////////////////////////////////////////////////////////////

@interface CIM_BulkMsgData : CCompressSockData
@property (nonatomic, assign) int64_t m_n64SenderID;
@property (nonatomic, assign) int32_t m_dwExprSeconds;
@property (nonatomic, assign) short m_sMsgType;
@property (nonatomic, strong) NSMutableArray <NSNumber *> *m_aGroupID;
@property (nonatomic, assign) NSString *m_strMsgText;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_BC_MsgData : CCompressSockData
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64SenderID;
@property (nonatomic, assign) int32_t m_dwExprSeconds;
@property (nonatomic, assign) short m_sMsgType;
@property (nonatomic, assign) NSString *m_strMsgText;
@property (nonatomic, assign) int64_t m_n64MsgID;
@property (nonatomic, assign) int32_t m_tmMsgTime;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_BC_CmdData :CCompressSockData
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64SenderID;
@property (nonatomic, assign) int32_t m_dwExprSeconds;
@property (nonatomic, assign) short m_sMsgType;
@property (nonatomic, assign) int64_t m_n64MsgID;
@property (nonatomic, assign) int32_t m_tmMsgTime;
@property (nonatomic, strong) NSString *m_strMsgText;
@end
//////////////////////////////////////////////////////////////////////

@interface CIM_DelMsgData : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64MsgID;
@property (nonatomic, assign) int64_t m_n64GrpMsgID;
@property (nonatomic, assign) int64_t m_n64GroupID;

@end
//////////////////////////////////////////////////////////////////////

@interface CIM_QueryMsgData : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64GrpMsgIDFrom;
@property (nonatomic, assign) int64_t m_n64GrpMsgIDTo;
    //Recv
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_QueryMemberData : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@end

//////////////////////////////////////////////////////////////////////
@class CIM_UploadData;
typedef void (^ uploadCompletionBlocl) (CIM_UploadData *uploadObjcet, BOOL success);
@interface CIM_UploadData:CCompressSockData
@property (nonatomic, assign) Byte m_cFileType;  // 1: File, 2: Pic
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64FileID;
@property (nonatomic, assign) Byte m_cNextStep;  	// 1 = User Portrait, 2 = Group Portrait
@property (nonatomic, strong) EMFileData  *m_Data;
@property (nonatomic, strong) NSString *m_strFileName;
@property (nonatomic, assign) int32_t  m_dwSendPos;
@property (nonatomic, assign) BOOL finishUpload;
@property (nonatomic, copy) uploadCompletionBlocl uploadCompletion;
- (void)startUploadFile;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_DownloadData:CCompressSockData{
}
@property (nonatomic, assign) Byte m_cFileType;  	//  1: File, 2: Pic
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int64_t m_n64FileID;
@property (nonatomic, strong) EMFileID * m_pFileID;
@property (nonatomic, assign) int32_t m_dwRecvPos;
@property (nonatomic, assign) int32_t m_dwFileSize;
@property (nonatomic, assign) int32_t m_dwTickCount;
@property (nonatomic, copy) SocketDownImages downImageBlocl;
@end
//////////////////////////////////////////////////////////////////////

@interface CIM_ModNickName : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) short m_wType;  // 1==ModNickName; 2==ModPortrait 3 ==签名
@property (nonatomic, strong) NSString *m_strNickName;
@property (nonatomic, assign) int64_t m_n64NewPortraitID;
@property (nonatomic, assign) int m_nRet;
@property (nonatomic, strong) NSString *m_strRet;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_ModGrpNickName : HandleDataModel
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) short m_wType; // // 1: 群昵称  2: 群名称  3: 群头像
@property (nonatomic, strong) NSString *m_strNickName;
@property (nonatomic, assign) int64_t m_n64NewPortraitID;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_ModGrpInfo : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) short m_wModType; // 1: 对方备注(COUPLE)|群备注NORMAL|客户备注SERVICE  2: 对方标签(SERVICE)  3: 已读消息  4: 群置顶
@property (nonatomic, assign) int64_t m_n64NewNum;
@property (nonatomic, strong) NSString *m_strNewText;
@property (nonatomic, assign) int m_nRet;
@property (nonatomic, strong) NSString *m_strRet;
@end

//////////////////////////////////////////////////////////////////////
@interface CIM_CreateBatGroup : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
//Send|Recv
@property (nonatomic, strong) CMassGroup *m_MassGroup;
@end;

//////////////////////////////////////////////////////////////////////

@interface CIM_ModBatGroup : CCompressSockData
//Send
@property (nonatomic, assign) int64_t m_n64UserID;
//Send|Recv
@property (nonatomic, strong) CMassGroup *m_MassGroup;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_DelBatGroup :  HandleDataModel
//Send
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64BatGroupID;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_QueryBatGroup : CCompressSockData
//Send
@property (nonatomic, assign) int64_t m_n64UserID;
//Send|Recv
@property (nonatomic, strong) NSMutableArray < CMassGroup *> *m_aMassGroup;
//    CMassGroupArrayS m_aMassGroup;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_BatGroupAdd : HandleDataModel
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64BatGroupID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) Byte m_cAdd;
@end

//////////////////////////////////////////////////////////////////////

@interface CIM_QueryServiceGroup : CCompressSockData
@property (nonatomic, assign) int64_t m_n64UserID;
@end;

//////////////////////////////////////////////////////////////////////

@interface CIM_QueryMsgAllData : CCompressSockData
//Send
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, strong) NSMutableArray *m_aQueryMsg;
//Recv//Other
@property (nonatomic, assign) int64_t m_lCount;
@property (nonatomic, assign) int32_t m_dwSysSecond;
@property (nonatomic, assign) int32_t m_dwTickCount;
- (void) getGroup;
@end
