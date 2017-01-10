
//
//  LoginDataModel.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CommDataModel.h"
#import "Buffer.h"
#import "UserInfo.h"
#import "MyDefine.h"
#import "EMCommData.h"
#import "RealmDbManager.h"
#import "EMFileData.h"
#import "EMLocalSocketManaget.h"
#import <EMSpeed/BDKNotifyHUD.h>

#define _SendBuffer_Size_  32*1024
#define g_n64SysMaxPortraitID  10000
@implementation CIMLB_LoginData
- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    char cAck = buffer.ReadChar();
    NSString *strRtb = @"";
    if (cAck == 1) {
        NSString *strAddress;
         strAddress  = buffer.ReadString();
        //AfxMessageBox(strAddress);
        int32_t wPort = buffer.ReadShort();
        //strAddress = "192.168.3.35";
//        theApp.WriteLocalProfileString("MsgServer", "Address", strAddress);
//        theApp.WriteLocalProfileInt("MsgServer", "Port", wPort);
//        strRtn = "OK";
    }else{
        strRtb = @"无可用MS服务器";
    }
    
//    if (buffer.GetBufferLen()>0)
//    {
//        CArray<CHost, CHost&> aHostNew;
//        CHost host;
//        host.m_cSys = 1;
//        host.m_nProtocol = 0;
//        
//        short sNum = buf.ReadShort();
//        for (short s=0; s<sNum; s++)
//        {
//            buf.ReadString(host.m_strName);
//            buf.ReadString(host.m_strAddress);
//            host.m_sPort = buf.ReadShort();
//            aHostNew.Add(host);
//        }
//        
//        int nNew = (int)aHostNew.GetSize();
//        
//    }
//    
//    CSockRet* pRet = new CSockRet;
//    if (pRet)
//    {
//        pRet->m_strRet = strRtn;
//        theApp.m_pMainWnd->PostMessage(MYWM_LB_LOGIN, cAck, (LPARAM)pRet);
//    }
//    
//    
//    if (m_pSocket)
//        m_pSocket->m_wStatus = CMySocket::WantDelete;
}

- (void) sendSockData:(CBuffer &)buffer{
    
    buffer.Write(&m_head, _DataHeadLength_);
    buffer.WriteChar(12);
    [self sendHead:buffer dataType:_DATA_L2LB_User_Login_];
    self.m_wStatus = WantRecv;
//    SendHead(buf, _DATA_L2LB_User_Login_);
//    m_wStatus = CSockData::WantRecv;
}
@end

@implementation CCheckData
//心跳
- (void)sendSockData:(CBuffer &)buffer{
//增加激活时间
//    if (m_pSocket && g_dwSysSecond-m_pSocket->m_dwActiveTime>10)
    {
        buffer.Add(_DataHeadLength_);
        [self sendHead:buffer dataType:_DATA_Check_*100+1];
//        SendHead(buf, _DATA_Check_*100+1);
    }
}
- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    NSLog(@"Heart Test");
    self.m_wStatus =WantRecv;
}
@end

@implementation CCheckAckData

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    [self sendHead:buffer dataType:_DATA_Check_*100 +1];
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    buffer.Write(&m_head, _DataHeadLength_);
    [self sendHead:buffer dataType:m_head->m_wDataType+1];
    self.m_wStatus =WantRecv;
}
@end
@implementation CIM_LoginData
- (id) init{
    self = [super init];
    if (self) {
        self.m_cCodeAlgorithm = DATAENCODE_RSA;
        self.m_strName = @"";
        self.m_strPassword = @"";
        self.m_nPlatformID = 1;
    }
    return self;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteStringShort(_m_strName);
    buffer.WriteStringShort(_m_strPassword);
    buffer.WriteInt(self.m_nPlatformID);
    m_head->m_wDataType = _DATA_IM_Login_;
    [self sendHead:buffer dataType:_DATA_IM_Login_];
    self.m_wStatus =  WantRecv;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    UserInfo *user = [[UserInfo alloc] init];;
    NSMutableArray *groupArray = [NSMutableArray array];
    int32_t nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    
    if (nRet < 0){
        [BDKNotifyHUD showNotifHUDWithText:strRet];
        if (self.completionBlock ) {
            self.completionBlock(nil,NO);
            return;
        }
    }
    [[EMCommData sharedEMCommData] setAccountLoginStatus:YES];
    [[EMLocalSocketManaget sharedSocketManaget] startHeartconnect];
    
    if (nRet >= 0 &&[self recvCompressData2:buffer]){
        CBuffer* pBufCompress = [self getCompress];
        if (pBufCompress == NULL){
            if (self.completionBlock ) {
                self.completionBlock(nil,NO);
            }
            return;
        }
        CBuffer& bufComp = *pBufCompress;
        user.m_n64AccountID = bufComp.ReadLong();
        user.m_strNickName = bufComp.ReadStringShort();
        user.m_n64PortraitID = bufComp.ReadLong();
        user.m_strSignature = bufComp.ReadStringShort();
        NSLog(@" id =%lld, nickname = %@ m_n64PortraitID = %lld", user.m_n64AccountID, user.m_strNickName, user.m_n64PortraitID);
        [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID =  user.m_n64AccountID;
        [EMCommData sharedEMCommData].selfUserInfo.m_strNickName = user.m_strNickName;
        [EMCommData sharedEMCommData].selfUserInfo.m_n64PortraitID = user.m_n64PortraitID;
        [EMCommData sharedEMCommData].selfUserInfo.m_strSignature = user.m_strSignature;
        
        [EMCommData sharedEMCommData].selfUserInfo.m_strUserName = _m_strName;
        [EMCommData sharedEMCommData].selfUserInfo.m_strPassword = _m_strPassword;
        [EMCommData sharedEMCommData].selfUserInfo.m_nPlatformID = _m_nPlatformID;
        [[NSUserDefaults standardUserDefaults] setObject:_m_strName forKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] setObject:_m_strPassword forKey:@"Password"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_m_nPlatformID] forKey:@"PlatformID"];
        
        int nGroupSize = bufComp.ReadShort();
        if (nGroupSize <= 0){
            nRet = -1;
            strRet = @"没有专属客服";
        }
        
        for (int i = 0; i < nGroupSize; i++){
            CGroup *group = [[CGroup alloc] init];
            group.m_n64AccountID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            group.m_n64GroupID = bufComp.ReadLong();
            group.m_dwPermissionFlag = bufComp.ReadInt();
            group.m_n64Peer_MinMsgID = bufComp.ReadLong();
            group.m_wGroupType = bufComp.ReadShort();
            group.m_n64MaxGrpMsgID = bufComp.ReadLong();
            group.m_dwMaxMsgSeconds = bufComp.ReadInt();
            group.m_strPeerGrpName = bufComp.ReadStringShort();
            if (group.m_wGroupType == TYPE_COUPLE)
                group.m_strNickName = bufComp.ReadStringShort();
            else
                group.m_strNickName = @"";
            group.m_n64PortraitID = bufComp.ReadLong();
            group.m_strPeerRemark = bufComp.ReadStringShort();
            group.m_n64ReadGrpMsgID = bufComp.ReadLong();
            group.m_strSignature = @"";
            group.m_nNumGrpMember = 0;
            
            if (group.m_wGroupType == TYPE_COUPLE)
                group.m_strSignature = bufComp.ReadStringShort();
            else
                group.m_nNumGrpMember = bufComp.ReadInt();
            [groupArray  addObject:group ];
            
            [[EMCommData sharedEMCommData]  addNewGroup:group];
        }
        int nSelfSize = bufComp.ReadShort();
        int nPeerSize = bufComp.ReadShort();
    }
    if (nRet==0){
        self.islogin = YES;
        NSLog(@"MsgSerVer登陆成功");
//        已经实现
        CIM_QueryServiceGroup* pDataQuery1 = [[CIM_QueryServiceGroup alloc] init];
        if (pDataQuery1){
            pDataQuery1.m_n64UserID = user.m_n64AccountID;
            pDataQuery1.m_wStatus = WantSend;
            pDataQuery1.completionBlock = self.completionBlock;
            [pDataQuery1 sendSockPost];
        }
//        再无实习，请求正常，返回-1
//        CIM_QueryBatGroup* pDataQuery2 =  [[CIM_QueryBatGroup alloc] init];
//        if (pDataQuery2)
//        {
//            pDataQuery2.m_n64UserID = user.m_n64AccountID;
//            pDataQuery2.m_wStatus = WantSend;
//        //    [pDataQuery2 setCompletionBlock:self.completionBlock];
//            [pDataQuery2 sendSockPost];
//        }
//        已经实现
        CIM_QueryMsgAllData* pDataQueryMsg = [[CIM_QueryMsgAllData alloc] init];
        pDataQueryMsg.m_aQueryMsg = [NSMutableArray array];
        for (int i = 0; i < groupArray.count; i ++) {
            CGroupBase *tempGoup = [groupArray objectAtIndex:i];
            CQueryMsg *tempMsg = [[CQueryMsg alloc] init];
            tempMsg.m_n64GroupID = tempGoup.m_n64GroupID;
            tempMsg.m_n64MaxMsgID = tempGoup.m_n64MaxGrpMsgID;
            tempMsg.m_n64RecvMsgID  =tempGoup.m_n64MaxGrpMsgID -1;
            [pDataQueryMsg.m_aQueryMsg addObject:tempMsg];
        }
//
        if (pDataQueryMsg){
            pDataQueryMsg.m_n64UserID = user.m_n64AccountID;
            pDataQueryMsg.m_wStatus = WantSend;
            [pDataQueryMsg sendSockPost];
        }
        
        CIM_BC_MsgData* pDataMsg =[[CIM_BC_MsgData alloc] init];
        if (pDataMsg)
        {
            pDataMsg.m_wStatus = WantAll;
            [pDataMsg sendSockPost];
        }
        
        CIM_BC_CmdData* pDataCmd = [[CIM_BC_CmdData alloc] init];
        if (pDataCmd)
        {
            pDataCmd.m_wStatus = WantAll;
            [pDataCmd sendSockPost];
        }
    }
    
    if (user.m_n64AccountID>0){
        //目前不清楚什么作用
//        theApp.SetUser(user, TRUE);
//        theApp.SetGroup(aGroup, TRUE);
    }
    
//    if (g_IsWindow(theApp.m_pMainWnd))
//    {
//        CSockRet* pRet = NULL;
//        if (nRet)
//        {
//            pRet = new CSockRet;
//            if (pRet)
//                pRet->m_strRet = strRet;
//        }
//        
//        theApp.m_pMainWnd->PostMessage(MYWM_LOGIN, nRet, (LPARAM)pRet);
//    }
    self.m_wStatus = WantDelete;
    if (nRet == 0){
        self.m_wStatus = WantAll;
//        pSocket->m_wStatus = WantAll;
        
    }else{
        self.m_wStatus = WantDelete;
    }
//    if (self.completionBlock ) {
//       self.completionBlock(nil,YES);
//    }
}
@end

@implementation  CIM_NewsMsgData

- (id)init{
    self = [super init];
    if (self) {
        _m_n64GroupID = 0;
        _m_n64SenderID = 0;
        _m_dwExprSeconds = 0;
        _m_sMsgType = 0;
        _m_n64MsgID = 0;
        _m_n64GrpMsgID = 0;
        _m_dwMsgSeconds = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    bufComp.ClearBuffer();
    bufComp.WriteLong(_m_n64GroupID);
    bufComp.WriteLong(_m_n64SenderID);
    bufComp.WriteInt(_m_dwExprSeconds);
    bufComp.WriteShort(_m_sMsgType);
    bufComp.WriteStringShort(_m_strMsgText);
    [self compress2Buf:buffer wDataType:_DATA_IM_NewMsg_];
    self.m_wStatus = WantAll;
}

@end

@implementation CIM_BulkMsgData

- (id)init{
    self = [super init];
    if (self) {
        _m_n64SenderID = 0;
        _m_dwExprSeconds = 0;
        _m_sMsgType = 0;
        _m_strMsgText = @"";
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    if (nRet >0) {
        return;
    }
    NSString *strRet = buffer.ReadStringShort();
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    bufComp.ClearBuffer();
    
    bufComp.WriteLong(_m_n64SenderID);
    bufComp.WriteInt(_m_dwExprSeconds);
    bufComp.WriteShort(_m_sMsgType);
    bufComp.WriteStringShort(_m_strMsgText);
    
    short wSize = self.m_aGroupID.count;
    bufComp.WriteShort(wSize);
    
    for (short w=0; w<wSize; w++)
    {
        NSNumber *tempValue = self.m_aGroupID[w];
        bufComp.WriteLong(tempValue.longLongValue);
    }
    [self compress2Buf:buffer wDataType:_DATA_IM_BulkMsg_];
}
@end

@implementation CIM_BC_MsgData

- (id)init{
    self = [super init];
    if (self) {
        _m_n64GroupID = 0;
        _m_n64SenderID = 0;
        _m_dwExprSeconds = 0;
        _m_sMsgType = 0;
        _m_strMsgText = @"";
        _m_n64MsgID = 0;
        _m_tmMsgTime = 0;
    }
    return self;
}

int nRecv_BC_Msg = 0;
- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    if ([self recvCompressData:buffer]==FALSE)
        return;
    CBuffer* pBufCompress = [self getCompress];
    
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    int64_t n64MsgID, n64GroupID, n64GrpMsgID;
    CGroup* pGroup = NULL;
    NSMutableArray<CGroup *> *aGroup;
    int nSize = bufComp.ReadShort();
        
    nRecv_BC_Msg += nSize;
    bool bShowNotify = false;
    for (int i=0; i<nSize; i++)
    {
        n64MsgID =  bufComp.ReadLong();
        n64GroupID = bufComp.ReadLong();
        n64GrpMsgID = bufComp.ReadLong();
       
        CGroupBase *tempBae = [[EMCommData sharedEMCommData] getGroupbyid:n64GroupID];
        CGroup *pGroup = [[CGroup alloc] init];
        [pGroup setGroupMessage:tempBae];
        if (!pGroup) {
            break;
        }
        CNewMsg* pNewMsg = [pGroup createMsg:n64GrpMsgID];
   
//        if (pNewMsg==NULL || pNewMsg.m_pGroup==NULL)
//            break;
        short wMsgType = 0;
        int64_t nDelGrpMsgID = 0;
        pNewMsg.m_n64MsgID = n64MsgID;
        pNewMsg.m_dwMsgSeconds = bufComp.ReadInt();
        pNewMsg.m_n64SenderID = bufComp.ReadLong();
        wMsgType = pNewMsg.m_sMsgType = bufComp.ReadShort();
        pNewMsg.m_strMsgText = bufComp.ReadString();
        pNewMsg.m_dwExprSeconds = bufComp.ReadInt();
        pNewMsg.m_n64GroupID = pGroup.m_n64GroupID;
        [pNewMsg AfterRecv];
        [[EMCommData sharedEMCommData] addNewMsg:pNewMsg needNotice:YES];
    
    //  代码为实现
//        if (g_IsWindow(pGroup->m_pWnd) && pGroup->m_pWnd->IsWindowVisible())
//        {
//            pGroup->m_pWnd->PostMessage(MYWM_FLASHWINDOW, 0, 0);
//        }
//        else
//        {
//            bShowNotify = TRUE;
//        }
        
//        if (pGroup->UpdateMsg(pNewMsg, TRUE))
//            aGroup.Add(pGroup);
//        }
        
//        pGroup->m_wr.EndWrite();
    
//        pGroup.m_bWantSave = TRUE;
    }
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    [self sendHead:buffer dataType:_DATA_IM_BC_Msg_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_BC_CmdData

- (id)init{
    self = [super init ];
    if (self) {
        _m_n64GroupID = 0;
        _m_n64SenderID = 0;
        _m_dwExprSeconds = 0;
        _m_sMsgType = 0;
        _m_strMsgText = @"";
        _m_n64MsgID = 0;
        _m_tmMsgTime = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData: head sendbuffer:buffer];
    if ( [self recvCompressData:buffer]==FALSE)
        return;
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    int64_t n64CmdID = 0;
    int nSize = bufComp.ReadShort();
    
    for (int i=0; i<nSize; i++)
    {
        n64CmdID = bufComp.ReadLong();
        if (n64CmdID<=0)
            break;
        //聊天的消息发送，有待实现
        CChatCmd* pCmd = [[CChatCmd alloc] init];;
        if (pCmd==NULL)
            break;
        pCmd.m_n64CmdID = n64CmdID;

        pCmd.m_dwSeconds = bufComp.ReadInt();
        pCmd.m_wType = bufComp.ReadShort();
        int32_t bufflegth;
        bufComp.Read(&bufflegth, 4);
        Byte *bath =(Byte *)malloc(bufflegth +1);
        bufComp.Read(bath, bufflegth);
        pCmd.m_Data = [[NSData alloc] initWithBytes:bath length:bufflegth];
        [pCmd doCmd];
//        pCmd.m_Data.Read(bufComp, 4);
    }
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    [self sendHead:buffer dataType:_DATA_IM_BC_Cmd_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_DelMsgData
- (id) init{
    self  =[super init];
    if (self) {
       	_m_n64UserID = 0;
        _m_n64MsgID = 0;
        _m_n64GroupID = 0;
        _m_n64GrpMsgID = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64MsgID);
    buffer.WriteLong(_m_n64GroupID);
    buffer.WriteLong(_m_n64GrpMsgID);
    [self sendHead:buffer dataType:_DATA_IM_DelMsg_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_QueryMsgData
- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_n64GroupID = 0;
        _m_n64GrpMsgIDFrom = 0;
        _m_n64GrpMsgIDTo = 0;
    }
    return self;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64GroupID);
    buffer.WriteLong(_m_n64GrpMsgIDFrom);
    buffer.WriteLong(_m_n64GrpMsgIDTo);
    [self sendHead:buffer dataType:_DATA_IM_QueryMsg_];
    self.m_wStatus = WantRecv;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString  *strRet = buffer.ReadStringShort();
    
    if (nRet<=0){
        [BDKNotifyHUD showNotifHUDWithText: strRet];
        return;
    }
    
    if (![self recvCompressData2:buffer])
        return;
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    //有待完成
    CGroup* pGroup = [[EMCommData sharedEMCommData ] getGroupbyid:_m_n64GroupID];  //theApp.GetGroup(m_n64GroupID);
    if (pGroup==NULL)
        return;
    
    int64_t n64MsgID, n64GrpMsgID;
    
    int nSize = bufComp.ReadShort();
    
    for (int i=0; i<nSize; i++)
    {
        n64MsgID = bufComp.ReadLong();
        n64GrpMsgID = bufComp.ReadLong();
        
        CNewMsg* pNewMsg = [pGroup createMsg:n64GrpMsgID];
        
        if (pNewMsg==NULL || pNewMsg.m_pGroup==NULL)
            break;
        
        short wMsgType = 0;
        int64_t nDelGrpMsgID = 0;
        pNewMsg.m_n64MsgID = n64MsgID;
        pNewMsg.m_n64GroupID = pGroup.m_n64GroupID;
        
        pNewMsg.m_n64SenderID = bufComp.ReadLong();
        pNewMsg.m_dwMsgSeconds = bufComp.ReadInt();
        pNewMsg.m_dwExprSeconds = bufComp.ReadInt();
        
        wMsgType = pNewMsg.m_sMsgType = bufComp.ReadShort();
        pNewMsg.m_strMsgText = bufComp.ReadString();
        [pNewMsg AfterRecv];
        [[EMCommData sharedEMCommData] addNewMsg:pNewMsg needNotice:NO];
        [pGroup updateMessage:pNewMsg addcount:true];
        pGroup.m_bWantSave = TRUE;
    }
    if (self.completionBlock) {
        self.completionBlock(nil,YES);
    }
    self.m_wStatus =WantDelete;
}

@end


@implementation CIM_QueryMemberData

- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_n64GroupID = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet =buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    
    if (nRet<=0){
        [BDKNotifyHUD showNotifHUDWithText: strRet];
        return;
    }
    if (![self recvCompressData2:buffer])
        return;
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    NSMutableArray <CGroupMember *> *aMember;
    int nSize = bufComp.ReadShort();
    
    for (int i=0; i<nSize; i++)
    {   CGroupMember *gm = [[CGroupMember alloc] init];
        gm.m_n64UserID = bufComp.ReadLong();
        gm.m_strMbrNickName = bufComp.ReadStringShort();
        gm.m_strNickName = bufComp.ReadStringShort();
        gm.m_n64PortraitID = bufComp.ReadLong();
        [aMember addObject:gm];
    }
    CGroup* pGroup = [[CGroup alloc] init];
    //theApp.GetGroup(m_n64GroupID);
    if (pGroup==NULL)
        return;
    pGroup.m_bQueryMemberDone = TRUE;
    
//    pGroup->CopyMember(aMember);
//    if (g_IsWindow(theApp.m_pMainWnd))
//        theApp.m_pMainWnd->PostMessage(MYWM_MESSAGE, _DATA_IM_QueryMember_, (LPARAM)pGroup);
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    
    buffer.Add(_DataHeadLength_);
    
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64GroupID);
    [self sendHead:buffer dataType:_DATA_IM_QueryMember_];
    self.m_wStatus = WantRecv;
}

@end

@implementation CIM_UploadData

- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_n64GroupID = 0;
        _m_cFileType = 0;
        _m_n64FileID = 0;
        _m_dwSendPos = 0;
        _m_cNextStep = 0;
        _finishUpload = NO;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
//    [BDKNotifyHUD showNotifHUDWithText: strRet];
    Byte cFileType = buffer.ReadChar();
    _m_n64FileID = buffer.ReadLong();
    NSFileManager *tempFileManager = [[NSFileManager alloc] init];
    NSString *strPathName = [NSString stringWithFormat:@"%@/%d/%lld.%@", [[EMCommData sharedEMCommData] commFilePath], _m_cFileType,_m_n64FileID,_m_strFileName];
    NSError *error = nil;
    if (self.uploadCompletion) {
        self.uploadCompletion(self,nRet ==0 ? YES:NO);
    }
    [tempFileManager copyItemAtPath:self.m_Data.descfilePath toPath:strPathName error:&error];
    if (error) {
        
    }
    if (nRet==0 && _m_cFileType==cFileType){
        if (_m_n64FileID>0){
            self.m_wStatus = WantDelete;
            if (_m_cFileType == FT_Portrait){
                int64_t n64NewPortraitID = _m_n64FileID + g_n64SysMaxPortraitID;
                EMFileID *pFileID =[[EMCommData sharedEMCommData] addFileid:_m_cFileType n64FileId:n64NewPortraitID strFileName:_m_strFileName mData:_m_Data boverWrite:NO];
                if (pFileID)
                if (_m_cNextStep == 1){
                    CIM_ModNickName* pData =[[CIM_ModNickName alloc] init];
                    if (pData==NULL)
                        return;
                    pData.m_n64UserID = _m_n64UserID;
                    pData.m_wType = 2;
                    pData.m_n64NewPortraitID = n64NewPortraitID;
//                    theApp.AddSockData(pData);
                }else if (_m_cNextStep == 2){
                    CIM_ModGrpNickName* pData = [[CIM_ModGrpNickName alloc] init];;
                    if (pData==NULL)
                        return;
                    pData.m_n64UserID = _m_n64UserID;
                    pData.m_n64GroupID = _m_n64GroupID;
                    pData.m_wType = 3;
                    pData.m_n64NewPortraitID = n64NewPortraitID;
//                    theApp.AddSockData(pData);
                }
            }
        }else{
          self.m_wStatus = WantRecv;
        }
    }else
         self.m_wStatus =WantDelete;
}

- (void)startUploadFile{
    while (!self.finishUpload) {
        [self sendSockPost];
    }
}

- (void)sendSockData:(CBuffer &)buffer{
   	Byte* pcData = self.m_Data.m_pcBuffer;
    if (self.m_Data.m_dwSize <_m_dwSendPos || pcData==NULL){
        self.m_wStatus = WantDelete;
        self.finishUpload = YES;
        return;
    }
    CBuffer* pBufCompress =  [self getCompress];//self->compressbuffer;
    if (!pBufCompress)
        return;
    CBuffer& bufComp = *pBufCompress;
    bufComp.ClearBuffer();
    Byte cStatus = 0;
    if (_m_dwSendPos==0){
        cStatus |= 0x01;
        _finishUpload = NO;
    }
    
    int32_t dwSendNum = self.m_Data.m_dwSize - _m_dwSendPos;
    
    if (dwSendNum <= _SendBuffer_Size_){
        cStatus |= 0x02;
        _finishUpload =YES;
    }else{
        dwSendNum = _SendBuffer_Size_;
        _finishUpload = NO;
    }
    bufComp.WriteChar(cStatus);
    if (cStatus & 0x01){
        bufComp.WriteChar(2);
        bufComp.WriteLong(_m_n64UserID);
        bufComp.WriteLong(_m_n64GroupID);
        bufComp.WriteString(self.m_strFileName);//self.m_strFileName);
        bufComp.WriteInt((int)self.m_Data.m_dwSize);
        bufComp.Write([self.m_Data getpcHash], 16);
    }
    bufComp.WriteInt(_m_dwSendPos);
    bufComp.WriteInt(dwSendNum);
    
    if (dwSendNum>0){
        for(int i = dwSendNum - 50;i < dwSendNum; i++){
            NSLog(@" filedata %d: %d",i,pcData[i+_m_dwSendPos]);
        }
        bufComp.Write(pcData +_m_dwSendPos, dwSendNum);
        _m_dwSendPos += dwSendNum;
    }
    [self compress2Buf:buffer wDataType:_DATA_IM_Upload_];
    for(int i = 20;i < 120; i++){
        NSLog(@" comPressData  %d: %d",i-16,(char)buffer.GetBuffer()[i]);
    }
    
    for(int i = buffer.GetBufferLen() - 100;i <  buffer.GetBufferLen(); i++){
        NSLog(@" compressedData %d: %d",i -16,(char)buffer.GetBuffer()[i]);
    }
    if (cStatus & 0x02)
         self.m_wStatus = WantRecv;
    else
         self.m_wStatus = WantSend;
}
@end

@implementation CIM_DownloadData

- (id) init{
    self = [super init];
    if (self) {
        _m_cFileType = 0;
        _m_n64UserID = 0;
        _m_n64GroupID = 0;
        _m_n64FileID = 0;
        _m_dwFileSize = 0;
        _m_dwRecvPos = 0;
        _m_dwTickCount = 0;
        _m_pFileID = [[EMFileID alloc] init];
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    
    [super recvSockData: head sendbuffer:buffer];
    if (![self recvCompressData:buffer])
        return;
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    Byte cStatus = bufComp.ReadChar();
    /*
     if (m_dwRecvPos==0)
     ASSERT(cStatus & 0x01);
     */
    if (cStatus & 0x01){
        _m_pFileID.m_nRet = bufComp.ReadInt();
        _m_pFileID.m_strRet = bufComp.ReadStringShort();
        
        if (_m_pFileID.m_nRet==0){
            _m_pFileID.m_cType = bufComp.ReadChar();
            _m_pFileID.m_n64UserID = bufComp.ReadLong();
            _m_pFileID.m_n64GroupID = bufComp.ReadLong();
            _m_pFileID.m_strFileName = bufComp.ReadString();
            _m_dwFileSize = bufComp.ReadInt();
            bufComp.Read([_m_pFileID getpcHash], 16);
        }
    }
    if (_m_pFileID.m_nRet!=0){
        _m_pFileID.m_cStatus = STATUS_ERROR;
        self.m_wStatus =WantDelete;
        return;
    }
    if (cStatus & 0x01){
//        ASSERT(m_dwRecvPos==0);
        _m_pFileID.m_Data = [[EMFileData alloc] init];
        [_m_pFileID.m_Data  allocNewSize:_m_dwFileSize];
        _m_pFileID.m_n64FileID = self.m_n64FileID;
    }
    
    if (![_m_pFileID.m_Data getData]){
        _m_pFileID.m_cStatus = STATUS_ERROR;
        cStatus = WantDelete;
        return;
    }
    Byte* pcData = [_m_pFileID.m_Data getData];
    
    int32_t dwSendPos = bufComp.ReadInt();
    if(dwSendPos != _m_dwRecvPos){
        return;
    }
    
    int32_t dwRecvNum = bufComp.ReadInt();
    if(dwRecvNum >= 0x10000) return;
    
    if (dwRecvNum>0)
    {
        bufComp.Read(pcData + _m_dwRecvPos, dwRecvNum);
        _m_dwRecvPos += dwRecvNum;
        _m_pFileID.m_Data.m_dwSize += dwRecvNum;
    }
    if (_m_dwRecvPos >_m_dwFileSize) {
        return;
    }

    if (_m_dwRecvPos==_m_dwFileSize){
        if (!(cStatus & 0x02)) {
            return;
        }
        
        if (_m_pFileID.m_Data.m_dwSize!=_m_dwFileSize) {
            return;
        }
        
        [_m_pFileID.m_Data createMd5];
        if (memcmp([_m_pFileID getpcHash], [_m_pFileID.m_Data getpcHash], 16)!=0){
            _m_pFileID.m_cStatus =STATUS_ERROR;
            cStatus =WantDelete;
        }
        else{
            [_m_pFileID writeFile];
            _m_pFileID.m_cStatus = STATUS_OK;
            if (self.downImageBlocl) {
                self.downImageBlocl(_m_pFileID.m_pImage,YES);
            }
            
            [[EMCommData sharedEMCommData] addHash2ID:_m_pFileID.m_cType  hash2id:[[EMHash2ID alloc] initWithHash:[_m_pFileID getpcHash]  fileId: _m_pFileID.m_n64FileID]];
            
            cStatus =WantDelete;
        }
    }
    else if (_m_pFileID.m_cPause == 1)
        cStatus = WantSendDelete;
    else
        cStatus = WantRecv;
    
    _m_pFileID.m_dwRecvSize = _m_dwFileSize;
    _m_pFileID.m_dwRecvPos = _m_dwRecvPos;

    if (_m_dwRecvPos == _m_dwFileSize || _m_pFileID.m_cPause == 1){
        
    }
}


- (void)sendSockData:(CBuffer &)buffer{
//    if (m_pFileID && m_pFileID->m_cPause == 1)
//    {
//        m_wStatus = CSockData::WantDelete;
//        return;
//    }
    int64_t n64FileID = _m_n64FileID;
    
    if (_m_cFileType == FT_Portrait)
    {
        if (_m_n64FileID < g_n64SysMaxPortraitID)
        {
           self.m_wStatus =WantDelete;
            return;
        }
        else
            _m_n64FileID = _m_n64FileID - g_n64SysMaxPortraitID;
    }
    
    buffer.Add(_DataHeadLength_);
    
    buffer.WriteChar(_m_cFileType);
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64GroupID);
    
    buffer.WriteLong(n64FileID);
    
    buffer.WriteInt(_m_dwFileSize);
    buffer.WriteInt(_m_dwRecvPos);
    [self sendHead:buffer dataType:_DATA_IM_Download_];
    self.m_wStatus =WantRecv;
}

@end


@implementation CIM_ModNickName

- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_wType = 1;
        _m_strNickName = @"";
        _m_n64NewPortraitID = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (self.completionBlock) {
        self.completionBlock(nil,nRet ==0  ?YES :NO);
    }
    if (nRet == 0) {
    }else{
       [BDKNotifyHUD showNotifHUDWithText: strRet];
    }
    self.m_wStatus  = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteShort(_m_wType);
    if (_m_wType == 2)
        buffer.WriteLong(_m_n64NewPortraitID);
    else
        buffer.WriteStringShort(_m_strNickName);
    
    [self sendHead:buffer dataType:_DATA_IM_ModNickName_];
    self.m_wStatus = WantRecv;
}

@end

@implementation CIM_ModGrpNickName

- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_n64GroupID = 0;
        _m_wType = 1;
        _m_strNickName = @"";
        _m_n64NewPortraitID = 0;
    }
    return self;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64GroupID);
    buffer.WriteShort(_m_wType);
    
    if (_m_wType == 3)
        buffer.WriteLong(_m_n64NewPortraitID);
    else
        buffer.WriteStringShort(_m_strNickName);
    [self sendHead:buffer dataType:_DATA_IM_ModGrpNickName_];
     self.m_wStatus = WantRecv;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet == 0) {
        
    }
    self.m_wStatus = WantDelete;
}
@end


@implementation CIM_ModGrpInfo
- (id) init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_n64GroupID = 0;
        _m_wModType = 1;
        _m_strNewText = @"";
        _m_n64NewNum = 0;
   
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet != 0){
       int iii = 0;
        [BDKNotifyHUD showNotifHUDWithText: strRet];
        if(self.completionBlock){
            self.completionBlock(nil,NO);
        }
    }else{
        if(self.completionBlock){
            self.completionBlock(nil,YES);
        }
    }
    
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    bufComp.ClearBuffer();
    
    bufComp.WriteLong(_m_n64UserID);
    bufComp.WriteLong(_m_n64GroupID);
    bufComp.WriteShort(_m_wModType);
    
    if (_m_wModType == 1)
        bufComp.WriteStringShort(_m_strNewText);
    else if (_m_wModType == 2)
        bufComp.WriteString(_m_strNewText);
    else if (_m_wModType == 3)
        bufComp.WriteLong(_m_n64NewNum);
    else if (_m_wModType == 4)
        bufComp.WriteChar((Byte)_m_n64NewNum);
    [self compress2Buf:buffer wDataType:_DATA_IM_ModGrpInfo_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_MsgData

- (id)init{
    self = [super init];
    if (self) {
        self.m_cCodeAlgorithm = DATAENCODE_XOR;
        _m_cType = 0;
        _m_n64GroupID = 0;
        _m_n64BatGroupID = 0;
        
        _m_n64SenderID = 0;
        _m_dwExprSeconds = 0;
        
        _m_n64MsgID = 0;
        _m_n64GrpMsgID = 0;
        _m_dwMsgSeconds = 0;
        
        _m_nPosUpload = -1;
        _m_cFileType = 0;
        _m_dwSendPos = 0;
        _m_dwTotalSize = 0;
        _m_dwTotalPos = 0;
        _m_bAnalysis = FALSE;
        self.m_aGroupID = [NSMutableArray array];
        _m_dwTickCount = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet !=0) {
        [BDKNotifyHUD showNotifHUDWithText: strRet];
    }
    if (self.completionBlock ) {
        self.completionBlock(nil,nRet >0 ? YES: NO);
    }
    if (_m_cFileType == 0){
        if (_m_cType == 0){
        }
    }else{
        if (nRet != 0){
            
        }
    }
    if (_m_cFileType == 0){
        if (_m_cType == 1){
            if (!(nRet == _m_aGroupID.count)) {
                NSLog(@"Test Send Data 1");
                return;
            }
        }else if (_m_cType == 0){
            if (!(nRet == 0)) {
                NSLog(@"Test Send Data 1");
                return;
            }
            self.m_wStatus =WantDelete;
        }
    }
    else{
        Byte cFileType = buffer.ReadChar();
        int64_t n64FileID = buffer.ReadLong();
        
        if (nRet == 0 && _m_cFileType == cFileType)
        {
            int nSizeItem = (int)self.m_msg.m_aItem.count;
            if(_m_nPosUpload<0 || _m_nPosUpload >= nSizeItem){
                return ;
            }
            if (_m_nPosUpload >= 0 && _m_nPosUpload < nSizeItem){
                CMsgItem *item =(CMsgItem *)_m_msg.m_aItem[_m_nPosUpload];
                if(item.m_cType == MSG_ITEM_TEXT || item.m_cType == MSG_ITEM_ICON || item.m_n64FileID <= 0){
                    return;
                }
                if (item.m_cType != MSG_ITEM_TEXT && item.m_cType != MSG_ITEM_ICON && item.m_n64FileID <= 0){
                    if (_m_pFileID){
                        item.m_n64FileID = n64FileID;
                        item.m_pFileID =  [[EMCommData sharedEMCommData]addFileid:_m_cFileType n64FileId:n64FileID strFileName:_m_strFileName mData: _m_pFileID.m_Data boverWrite:(_m_pFileID.m_dwRecvPos == _m_pFileID.m_dwRecvSize)];
                        _m_pFileID.m_cStatus =STATUS_OK;
                    }
                }
            }
            _m_cFileType = 0;
            _m_pFileID = NULL;
            self.m_wStatus = WantSend;
        }
        else{
            self.m_wStatus = WantDelete;
        }
    }
}

- (void)sendSockData:(CBuffer &)buffer{
    if (!_m_bAnalysis) {
        [self analysis];
    }
    if (_m_cFileType == 0){
        int nSizeItem = (int)_m_msg.m_aItem.count;
        for (int i=0; i<nSizeItem; i++)
        {
            CMsgItem *item = [_m_msg.m_aItem objectAtIndex:i];
            
            if (item.m_cType == MSG_ITEM_TEXT || item.m_cType == MSG_ITEM_ICON)
                continue;
            if (item.m_pFileID == NULL)
                continue;
            
            if (item.m_n64FileID < 0){
                NSString *strPathName = item.m_strItem;
                if (item.m_cType == MSG_ITEM_IMAGE){
                    _m_cFileType = 2;
                }
                else{
                    _m_cFileType = 1;
                }
                
                _m_pFileID = item.m_pFileID;
                _m_dwSendPos = 0;
                _m_nPosUpload = i;
                
                break;
            }
        }
    }
    
    if (_m_cFileType == 0){
        NSString *strMsgText =[_m_msg Item2Text];
        if (strMsgText&&strMsgText.length > 0)
        {
            CBuffer* pBufCompress = [self getCompress];
            if (pBufCompress == NULL)
                return;
            CBuffer& bufComp = *pBufCompress;
            
            bufComp.ClearBuffer();
            
            if (_m_cType == 1)
            {
                bufComp.WriteLong(_m_n64SenderID);
                bufComp.WriteInt(_m_dwExprSeconds);
                
                bufComp.WriteShort(MSG_TEXT);
                bufComp.WriteString(strMsgText);
                
                int32_t wSize = (int32_t)_m_aGroupID.count;
                bufComp.WriteShort(wSize);
                
                for (int32_t w=0; w<wSize; w++)
                {
                    NSNumber *teamp =[_m_aGroupID objectAtIndex:w];
                    bufComp.WriteLong(teamp.longValue);
                }
                [self compress2Buf:buffer wDataType:_DATA_IM_BulkMsg_];
            }
            else if (_m_cType == 2)
            {
                bufComp.WriteLong(_m_n64SenderID);
                bufComp.WriteLong(_m_n64BatGroupID);
                bufComp.WriteInt(_m_dwExprSeconds);
                
                bufComp.WriteShort(MSG_TEXT);
                bufComp.WriteString(strMsgText);
                [self compress2Buf:buffer wDataType:_DATA_IM_BatGrpMsg_];
            }else{
                bufComp.WriteLong(_m_n64GroupID);
                bufComp.WriteLong(_m_n64SenderID);
                bufComp.WriteInt(_m_dwExprSeconds);
                bufComp.WriteShort(MSG_TEXT);
                bufComp.WriteString(strMsgText);
                [self compress2Buf:buffer wDataType:_DATA_IM_NewMsg_];
            }
        }
        else
        {
            self.m_wStatus = WantDelete;
        }
    }
    else if (_m_pFileID){
        NSData *pcData = [[NSData alloc] init]; //或者文件的数据，目前没实现
        
        CBuffer* pBufCompress = [self getCompress];//GetCompress();
        if (pBufCompress == NULL)
            return;
        CBuffer& bufComp = *pBufCompress;
        
        bufComp.ClearBuffer();
        
        Byte cStatus = 0;
        
        if (_m_dwSendPos==0)
            cStatus |= 0x01;
        
        int32_t dwSendNum =  0 ; //发送文件的长度，目前没算
        // m_pFileID->m_Data.m_dwSize - m_dwSendPos;
        
        if (dwSendNum <= _SendBuffer_Size_)
            cStatus |= 0x02;
        else
            dwSendNum = _SendBuffer_Size_;
        bufComp.WriteChar(cStatus);
        
        if (cStatus & 0x01){
            bufComp.WriteChar(_m_cFileType);
            bufComp.WriteLong(_m_n64SenderID);
            bufComp.WriteLong(_m_n64GroupID);
            bufComp.WriteString(_m_strFileName);
            bufComp.WriteInt(_m_pFileID.m_Data.m_dwSize);
            bufComp.Write([_m_pFileID.m_Data getpcHash], 16);
            _m_pFileID.m_dwRecvSize = _m_pFileID.m_Data.m_dwSize;
        }
        
        bufComp.WriteInt(_m_dwSendPos);
        bufComp.WriteInt(dwSendNum);
        
        if (dwSendNum>0)
        {
            bufComp.Write((Byte *)[pcData bytes] + _m_dwSendPos, dwSendNum);
            _m_dwSendPos += dwSendNum;
        }
        [self compress2Buf:buffer wDataType:_DATA_IM_Upload_];
        
        if (cStatus & 0x02)
            self.m_wStatus = WantRecv;
        else
           self.m_wStatus = WantSend;
    }
}


- (void)analysis{
    _m_dwTotalSize = 0;
    _m_dwTotalPos = 0;
    
    EMFileData *fd= [[EMFileData alloc] init];
    
    int nSizeItem = (int)_m_msg.m_aItem.count;
    for (int i=0; i<nSizeItem; i++)
    {
        CMsgItem* item = _m_msg.m_aItem[i];
        
        if (item.m_cType == MSG_ITEM_TEXT || item.m_cType == MSG_ITEM_ICON)
            continue;
        
        if (item.m_n64FileID == 0)
        {
            NSString *strPathName = item.m_strItem;
            if ([fd readFile:strPathName] && fd.m_dwSize>0)
            {
                [fd createMd5];
                Byte cFileType = (item.m_cType == MSG_ITEM_IMAGE) ? 2 : 1;
                int64_t n64FileID =[[EMCommData sharedEMCommData] hashID:cFileType pcHash:[fd getpcHash]];
              //为实现， 实现全局的文件流
                if (n64FileID != 0)
                {
                    item.m_n64FileID = n64FileID;
                    item.m_pFileID = [[EMCommData sharedEMCommData] addFileid:cFileType n64FileId:n64FileID strFileName:_m_strFileName mData:fd boverWrite:NO];
                }
            }
            else
            {
                item.m_n64FileID = 0;
            }
        }
    }
    _m_bAnalysis = TRUE;
}

- (void)finishFileID{
//    if (m_pFileID == NULL)
//        return;
//    
//    if (g_IsWindow(theApp.m_pMainWnd))
//    {
//        CGroup* pGroup = theApp.GetGroup(m_n64GroupID);
//        if (pGroup)
//        {
//            if (pGroup->DelItemUpload(m_pFileID))
//                theApp.m_pMainWnd->PostMessage(MYWM_MESSAGE, _DATA_IM_QueryMsg_, (LPARAM)pGroup);
//        }
//    }
}
@end

@implementation CIM_DelBatGroup
- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_n64BatGroupID = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet == 0) {
        [[EMCommData sharedEMCommData] deleteMassGroup:self.m_n64BatGroupID];
        if (self.completionBlock) {
            self.completionBlock(nil,YES);
        }
    }
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64BatGroupID);
    [self sendHead:buffer dataType:_DATA_IM_DelBatGrp_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_CreateBatGroup

- (id)init{
    self = [super init];
    if (self) {
       _m_n64UserID = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet<0){
        [BDKNotifyHUD showNotifHUDWithText: strRet];
        self.completionBlock(nil,NO);
        return;
    }
    
    if (![self recvCompressData2:buffer])
        return;
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
//    _m_MassGroup.m_n64BatGroupID = bufComp.ReadLong();
//    [_m_MassGroup.m_aGroupID removeAllObjects];
//    int64_t n64GroupID = 0, n64MemberID = 0;
//    short sSize = bufComp.ReadShort();
//    for (short s=0; s<sSize; s++)
//    {
//        n64GroupID = bufComp.ReadLong();
//        n64MemberID = bufComp.ReadLong();
//        [_m_MassGroup.m_aGroupID addObject:[NSNumber numberWithLongLong:n64GroupID]];
//    }
//    [self.m_MassGroup createMD5];
//    [[EMCommData sharedEMCommData] updateMassGroup: _m_MassGroup];
    if (self.completionBlock) {
        self.completionBlock(nil,YES);
    }
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    bufComp.ClearBuffer();
    bufComp.WriteLong(_m_n64UserID);
    bufComp.WriteStringShort(self.m_MassGroup.m_strName);
    short sSize = (short)[self.m_MassGroup.m_aGroupID count];
    bufComp.WriteShort(sSize);
    for (short s=0; s<sSize; s++){
        NSNumber *tempNumber=  [self.m_MassGroup.m_aGroupID objectAtIndex:s];
        bufComp.WriteLong(tempNumber.longLongValue);
    }
    [self compress2Buf:buffer wDataType:_DATA_IM_CrtBatGrp_];
    self.m_wStatus =WantRecv;
}

@end

@implementation CIM_ModBatGroup

- (id)init{
    self = [super init];
    if (self) {
      	_m_n64UserID = 0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet<0){
        [BDKNotifyHUD showNotifHUDWithText:strRet];
        if (self.completionBlock) {
            self.completionBlock(nil,NO);
        }
        return;
    }
    
    if (![self recvCompressData2:buffer])
        return;
    
//    CBuffer* pBufCompress = [self getCompress];
//    if (pBufCompress == NULL)
//        return;
//    CBuffer& bufComp = *pBufCompress;
//
//    [self.m_MassGroup.m_aGroupID removeAllObjects];;
//    
//    int64_t n64GroupID = 0;
//    
//    short sSize = bufComp.ReadShort();
//    for (short s=0; s<sSize; s++)
//    {
//        n64GroupID = bufComp.ReadLong();
//        
//        [self.m_MassGroup.m_aGroupID addObject:[NSNumber numberWithLong:n64GroupID]];
//    }
//     [self.m_MassGroup  createMD5];
////为实现
//    [[EMCommData sharedEMCommData] updateMassGroup:_m_MassGroup];
    if (self.completionBlock) {
        self.completionBlock(nil,YES);
    }
//    theMassGroup.ChangeMassGroup(m_MassGroup);
    self.m_wStatus = WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    bufComp.ClearBuffer();
    
    bufComp.WriteLong(_m_n64UserID);
    bufComp.WriteLong(self.m_MassGroup.m_n64BatGroupID);
    
    short sSize = (short)[self.m_MassGroup.m_aGroupID count];
    bufComp.WriteShort(sSize);
    
    for (short s=0; s<sSize; s++)
    {
        NSNumber *tempValue = self.m_MassGroup.m_aGroupID[s];
        bufComp.WriteLong(tempValue.longLongValue);
    }
    [self compress2Buf:buffer wDataType:_DATA_IM_ModBatGrp_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_QueryBatGroup
- (id)init{
    self = [super init ];
    if (self) {
        _m_n64UserID = 0;
        _m_aMassGroup = [NSMutableArray array];
    }
    return self;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteLong(_m_n64UserID);
    [self sendHead:buffer dataType:_DATA_IM_QryBatGrp_];
    self.m_wStatus = WantRecv;
}

- (CMassGroup *)searchGroupby:(int64_t )groupId{
    for (CMassGroup *tempGroup in self.m_aMassGroup) {
        if (tempGroup.m_n64BatGroupID == groupId ) {
            return tempGroup;
        }
    }
    return nil;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData: head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    
    if (nRet<0){
        [BDKNotifyHUD showNotifHUDWithText:strRet];
        if (self.completionBlock) {
            self.completionBlock(nil,NO);
        }
        return;
    }
    if (![self recvCompressData2:buffer])
        return;
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    short sNum = bufComp.ReadShort();
    
    for (short s=0; s<sNum; s++){
        CMassGroup *mg = [[CMassGroup alloc] init];;
            mg.m_n64BatGroupID = bufComp.ReadLong();
            mg.m_strName = bufComp.ReadStringShort();
            bufComp.ReadShort();	//m_wNumGrpMember
        [_m_aMassGroup addObject:mg];
    }
     sNum = bufComp.ReadShort();
    
    for (int s=0; s<sNum; s++){
        int64_t batGroupId = bufComp.ReadLong();
        CMassGroup *ms = [self searchGroupby:batGroupId];
        int64_t n64GroupID = bufComp.ReadLong();
        int64_t n64MemberID = bufComp.ReadLong();
        if (ms){
           [ms.m_aGroupID addObject:[NSNumber numberWithLong:n64GroupID ]];
        }
    }
    int nSize = (int)[_m_aMassGroup count];;
    for (int i=0; i<nSize; i++)
    {
        CMassGroup *tempGroup =  [_m_aMassGroup objectAtIndex: i];
        [tempGroup createMD5];
    }
    [[EMCommData sharedEMCommData] setMassGroup:_m_aMassGroup];
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.completionBlock(nil,YES);
        }
            );
    }
    self.m_wStatus = WantDelete;
}
@end

@implementation CIM_BatGroupAdd
- (id)init{
    self = [super init ];
    if (self) {
        _m_n64UserID = 0;
        _m_n64BatGroupID = 0;
        _m_n64GroupID = 0;
        _m_cAdd = 1;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData: head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet == 0){
        
        
    }
    self.m_wStatus =- WantDelete;
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteLong(_m_n64UserID);
    buffer.WriteLong(_m_n64BatGroupID);
    buffer.WriteLong(_m_n64GroupID);
    buffer.WriteChar(_m_cAdd);
    [self sendHead:buffer dataType:_DATA_IM_BatGrpAddRmv_];
    self.m_wStatus = WantRecv;
}
@end


@implementation CIM_QueryServiceGroup

- (id)init{
    self = [super init];
    if (self) {
//        _m_n64UserID = 0;
        self.m_cCodeAlgorithm =0;
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData: head sendbuffer:buffer];
    int nRet = buffer.ReadInt();
    NSString *strRet = buffer.ReadStringShort();
    if (nRet<0){
        if (self.completionBlock ) {
            self.completionBlock(nil,NO);
        }
        [BDKNotifyHUD showNotifHUDWithText: strRet];
        return;
    }
    
    if (![self recvCompressData2:buffer])
        return;
    
    NSMutableArray  *aMember =[NSMutableArray array];
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    int nSelfSize = bufComp.ReadShort();
    
    for (int i = 0; i < nSelfSize; i++){
      CRecvGroupMember *rgm = [[CRecvGroupMember alloc] init];
        rgm.m_n64AccountID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        rgm.m_cSelf = 1;
        rgm.m_n64GroupID = bufComp.ReadLong();
        rgm.m_Member.m_strMbrNickName = bufComp.ReadStringShort();
        rgm.m_Member.m_dwPermissionFlag = bufComp.ReadInt();
        rgm.m_Member.m_strTag = bufComp.ReadString();
    
        [aMember addObject:rgm];
    }
    
    int nPeerSize = bufComp.ReadShort();
    
    for ( int i = 0; i < nPeerSize; i++){
        CRecvGroupMember *rgm = [[CRecvGroupMember alloc] init];
        rgm.m_n64AccountID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        rgm.m_cSelf = 0;
        rgm.m_n64GroupID = bufComp.ReadLong();
        rgm.m_Member.m_n64UserID =  bufComp.ReadLong();
        rgm.m_Member.m_strMbrNickName = bufComp.ReadStringShort();
        rgm.m_Member.m_dwPermissionFlag = bufComp.ReadInt();
        rgm.m_Member.m_strEM_UserName = bufComp.ReadStringShort();
        rgm.m_Member.m_strNickName = bufComp.ReadStringShort();
        rgm.m_Member.m_n64PortraitID = bufComp.ReadLong();
        [aMember addObject:rgm];
    }
     [[EMCommData sharedEMCommData] setGroupMe:aMember];
    self.m_wStatus = WantDelete;
    if (self.completionBlock) {
        self.completionBlock(nil,YES);
    }
    
}

- (void)sendSockData:(CBuffer &)buffer{
    buffer.Add(_DataHeadLength_);
    buffer.WriteLong(self.m_n64UserID);
    [self sendHead:buffer dataType:_DATA_IM_QrySvrGrp_];
    self.m_wStatus = WantRecv;
}
@end

@implementation CIM_QueryMsgAllData
- (id)init{
    self = [super init];
    if (self) {
        _m_n64UserID = 0;
        _m_lCount = 0;
        _m_dwSysSecond = 0;
        _m_dwTickCount = 0;
        _m_aQueryMsg = [NSMutableArray array];
    }
    return self;
}

- (void)recvSockData:(CDataHead &)head sendbuffer:(CBuffer &)buffer{
    [super recvSockData:head sendbuffer:buffer];
    if (![self recvCompressData:buffer])
        return;
    
    CBuffer* pBufCompress =[self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    int64_t n64GroupID = bufComp.ReadLong();
    _m_lCount++;
    CGroup* pGroup   = [[EMCommData sharedEMCommData] getGroupbyid:n64GroupID];
//    CGroupRL *pGroup = [[CGroupRL objectsWhere:[NSString stringWithFormat:@"n64GroupID == %lld",n64GroupID]] firstObject];
//    CGroup* pGroup = theApp.GetGroup(n64GroupID);
    if (!pGroup)
        return;
    Byte cEnd = bufComp.ReadChar();
    
    int64_t n64MsgID, n64GrpMsgID;
    int nSize = bufComp.ReadShort();
    
    for (int i=0; i<nSize; i++)
    {
        n64MsgID = bufComp.ReadLong();
        n64GrpMsgID = bufComp.ReadLong();
        CNewMsg *pNewMsg = [pGroup createMsg:n64GrpMsgID];
        pNewMsg.m_n64MsgID = n64MsgID;
        pNewMsg.m_n64GroupID = n64GroupID;
        pNewMsg.m_n64GrpMsgID = n64GrpMsgID;
        pNewMsg.m_n64SenderID = bufComp.ReadLong();
        pNewMsg.m_dwMsgSeconds = bufComp.ReadInt();
        pNewMsg.m_dwExprSeconds = bufComp.ReadInt();
        pNewMsg.m_sMsgType = bufComp.ReadShort();
        pNewMsg.m_strMsgText = bufComp.ReadString();
        [pNewMsg AfterRecv];
        [pGroup updateMessage:pNewMsg addcount:NO];
//        pGroup->UpdateMsg(pNewMsg, TRUE);
//        pGroup->m_wr.EndWrite();
        pGroup.m_bWantSave = TRUE;
        [[EMCommData sharedEMCommData] addNewMsg:pNewMsg needNotice:NO];
    }
    NSLog(@"count: %lld cendValue:%d",_m_lCount,cEnd);
//    if (cEnd>0) {
//        if (self.completionBlock) {
//            self.completionBlock(nil,YES);
//        }
//    }
//    int32_t dwTickCount = GetTickCount();
//    if (cEnd || m_dwTickCount + 500 < dwTickCount)
//    {
//        m_dwTickCount = dwTickCount;
//        
//        if (g_IsWindow(theApp.m_pMainWnd))
//            theApp.m_pMainWnd->PostMessage(MYWM_MESSAGE, _DATA_IM_QueryMsgAll_, NULL);
//    }
}

- (void)sendSockData:(CBuffer &)buffer{
    int nSize = (int)_m_aQueryMsg.count;
    if (nSize == 0){
        _m_aQueryMsg =[NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getQuerayMsg]];
    }
    
     nSize = _m_aQueryMsg.count;
    if (nSize == 0){
        return;
    }
    
    CBuffer* pBufCompress = [self getCompress];
    if (pBufCompress == NULL)
        return;
    CBuffer& bufComp = *pBufCompress;
    
    bufComp.ClearBuffer();
    
    bufComp.WriteLong(_m_n64UserID);
    
    bufComp.WriteInt(nSize);
    for (int i=0; i<nSize; i++)
    {
        CQueryMsg *qm = _m_aQueryMsg[i];
        bufComp.WriteLong(qm.m_n64GroupID);
        bufComp.WriteLong(qm.m_n64MaxMsgID);
        bufComp.WriteLong(qm.m_n64RecvMsgID);
    }
    [self compress2Buf:buffer wDataType:_DATA_IM_QueryMsgAll_];
    self.m_wStatus = WantAll;
}

- (void)getGroup{
    
    
    
}
@end




