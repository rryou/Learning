//
//  UserInfo.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "UserInfo.h"
#import "EMTypeConversion.h"
#import "stdlib.h"
#import "EMCommData.h"
#import "EMFileData.h"
@implementation UserInfo

- (id)init{
    self = [super init];
    if (self) {
        self.m_nPlatformID = 0;
        self.m_n64AccountID = 0;
        self.m_n64PortraitID  = 0;
//        self.m_strNickName = @"";
//        self.m_strSignature = @"";
//        self.m_strUserName = @"";
//        self.m_strPassword = @"";
    }
    return self;
}

- (void)read:(CBuffer &)buffer version:(short)wVersion{
    _m_n64AccountID = buffer.ReadLong();
    _m_n64PortraitID = buffer.ReadLong();
    _m_strNickName = buffer.ReadStringShort();
    
    if (wVersion >= 2)
        _m_strSignature = buffer.ReadStringShort();
    
    _m_strUserName = buffer.ReadStringShort();
    _m_strPassword = buffer.ReadStringShort();
    _m_nPlatformID = buffer.ReadInt();
}

- (void)write:(CBuffer &)buffer version:(short)wVersion{
    buffer.WriteLong(_m_n64AccountID);
    buffer.WriteLong(_m_n64PortraitID);
    buffer.WriteStringShort(_m_strNickName);
    
    if (wVersion >= 2)
        buffer.WriteStringShort(_m_strSignature);
    
    buffer.WriteStringShort(_m_strUserName);
    buffer.WriteStringShort(_m_strPassword);
    buffer.WriteInt(_m_nPlatformID);
}

+ (NSInteger )compareUserInfo:(UserInfo &)first secondUser:(UserInfo &)second{
    if ([first._m_strUserName isEqualToString:second._m_strUserName] ) {
        return 0;
    }else{
        return first._m_strUserName > second._m_strUserName;
    }
}
@end


@implementation CGroupMember

- (NSString *)getTagGroupName{
    NSString *strNickName;
    if (self.Gm_strPeerRemark&&self.Gm_strPeerRemark.length > 0) {
        return self.Gm_strPeerRemark;
    }
    
    if (_m_strMbrNickName&&_m_strMbrNickName.length >1) {
        strNickName = _m_strMbrNickName;
    }else if(_m_strNickName){
        strNickName  = _m_strNickName;
    }//Gm_strPeerRemark
    if (!_m_strEM_UserName || [_m_strEM_UserName isEqualToString:strNickName]) {
    }else if(!strNickName){
        strNickName = _m_strEM_UserName;
    }else{
        strNickName =  [NSString stringWithFormat:@"%@,%@",strNickName, _m_strEM_UserName];
    }
    return strNickName;

}

- (NSString *)getSigleName{
    NSString *strNickName;
    if (_m_strMbrNickName&&_m_strMbrNickName.length >1) {
        strNickName = _m_strMbrNickName;
    }else if(_m_strNickName){
        strNickName  = _m_strNickName;
    }//Gm_strPeerRemark
    if (!_m_strEM_UserName || [_m_strEM_UserName isEqualToString:strNickName]) {
        return strNickName;
    }else if(!strNickName){
        strNickName = _m_strEM_UserName;
    }else{
        strNickName =  [NSString stringWithFormat:@"%@,%@",strNickName, _m_strEM_UserName];
    }
    return strNickName;
}

- (NSString *)getNickName{
    NSString *strNickName = [self getSigleName];
    if (self.Gm_strPeerRemark&&self.Gm_strPeerRemark.length > 0) {
        strNickName = [NSString stringWithFormat:@"%@(%@)",self.Gm_strPeerRemark,strNickName];
    }
    return strNickName;
}

- (bool) isCustomer{
    return ((_m_dwPermissionFlag & 0x08) == 0);
}

+ (NSInteger )compareUserInfo:(CGroupMember &)first secondUser:(CGroupMember &)second{
    if (first._m_n64UserID == second._m_n64UserID) {
        return 0;
    }else{
        return first._m_n64UserID > second._m_n64UserID;
    }
}

@end

@implementation CNewMsg

- (id)init{
    self = [super init];
    if (self) {
        _m_n64MsgID = 0;
        _m_n64GroupID = 0;
        _m_n64GrpMsgID = 0;
        _m_dwMsgSeconds = 0;
        _m_n64SenderID = 0;
        _m_n64DeleterID = 0;
        _m_dwExprSeconds = 0;
        _m_sMsgType = 0;
        _m_aItem = [NSMutableArray array];
    }
    return self;
}

- (int64_t) getSortID{
    return _m_n64GrpMsgID;
}

- (void)readFile:(CBuffer &)buffer version:(short)wVersion{
    _m_n64MsgID = buffer.ReadLong();
    _m_n64GroupID = buffer.ReadLong();
    _m_dwMsgSeconds = buffer.ReadInt();
    
    _m_n64SenderID = buffer.ReadLong();
    
    /*
     m_cIsGrpMsg = buf.ReadChar();
     if (m_cIsGrpMsg)
     {
     m_strSndrNickName = buf.ReadStringShort();
     m_n64SndrPortraitID = buf.ReadLong();
     }
     */
    char cIsGrpMsg = buffer.ReadChar();
    if (cIsGrpMsg)
    {
        buffer.ReadStringShort();
        buffer.ReadLong();
    }
    
    _m_sMsgType = buffer.ReadShort();
    _m_strMsgText = buffer.ReadString();
    
    if (_m_sMsgType < 0)
        _m_n64DeleterID = _m_strMsgText.intValue;
    _m_dwExprSeconds = buffer.ReadInt();
}

- (void)writeFile:(CBuffer &)buffer version:(short)wVersion{
    buffer.WriteLong(_m_n64MsgID);
    buffer.WriteLong(_m_n64GroupID);
    buffer.WriteInt(_m_dwMsgSeconds);
    
    buffer.WriteLong(_m_n64SenderID);
    /*
     buf.WriteChar(m_cIsGrpMsg);
     if (m_cIsGrpMsg)
     {
     buf.WriteStringShort(m_strSndrNickName);
     buf.WriteLong(m_n64SndrPortraitID);
     }
     */
    buffer.WriteChar(0);	// cIsGrpMsg
    
    buffer.WriteShort(_m_sMsgType);
    //字符串转换，可能有问题
  //  NSData *tempStrdata =[EMTypeConversion VCharConvertNSData:_m_strMsgText];
    buffer.WriteString(_m_strMsgText);
    buffer.WriteInt(_m_dwExprSeconds);
}
//消息的显示，有待完成
- (bool) wantShow{
//   	if (_m_sMsgType == MSG_NOTICE)
//    {
//        return m_aItem.GetSize() == 1;
//    }
//    if (m_strMsgText.IsEmpty())
//        return FALSE;
    return TRUE;
}

- (NSString *)l_FindSubString:(NSString *)strText strFind:(NSString *)strFind startposition:(int64_t &)nStartPos{
     NSRange tempRang =  [strText rangeOfString:strFind];
    
    if (tempRang.location >= nStartPos&&tempRang.location!=NSNotFound)
    {
        NSString *strRet = [strText substringWithRange:NSMakeRange(nStartPos , tempRang.location - nStartPos)];
        nStartPos = tempRang.location + strFind.length;
        return strRet;
    }
    else
        return @"";
}

- (void)AfterRecv{
    if (!_m_pGroup)
        return;
    
    if (_m_sMsgType==MSG_FILE || _m_sMsgType==MSG_PIC)
    {
        Byte cFileType;
        if (_m_sMsgType==MSG_FILE)
            cFileType = FT_File;
        else
            cFileType = FT_Pic;
        
        NSString *strFileID = @"";
        NSString *strFileName = @"";
        NSRange findlocal = [_m_strMsgText rangeOfString:@"#"];
        int nPos = findlocal.location;
        if (nPos>=0)
        {
            strFileID =[_m_strMsgText substringToIndex:nPos + 1];
            //m_strMsgText.Left(nPos + 1);
            strFileName =[_m_strMsgText substringFromIndex:nPos + 1];
            //m_strMsgText.Mid(nPos + 1);
        }
        else
            strFileID = _m_strMsgText;
        
        int64_t n64FileID = strFileID.intValue;
        if (n64FileID>0){
            _m_pFileID = [[EMCommData sharedEMCommData] getFileid:cFileType n64FileId:n64FileID n64GroupID:_m_pGroup.m_n64GroupID bRead:false];
        }
    }
    else if (_m_sMsgType==MSG_TEXT)
    {
        [self Text2Item:_m_strMsgText];
        int nSizeItem = [_m_aItem count];
        for (int i=0; i<nSizeItem; i++)
        {
            CMsgItem *item = (CMsgItem *)[_m_aItem objectAtIndex:i];
            
            if ((item.m_cType == MSG_ITEM_IMAGE || item.m_cType == MSG_ITEM_FILE) && item.m_n64FileID > 0)
            {
                if (item.m_cType == MSG_ITEM_FILE)
                    item.m_pFileID = [[EMCommData sharedEMCommData] getFileid: FT_File n64FileId:item.m_n64FileID n64GroupID:_m_pGroup.m_n64GroupID bRead:NO];
                else
                    item.m_pFileID = [[EMCommData sharedEMCommData] getFileid:FT_Pic n64FileId:item.m_n64FileID n64GroupID: _m_pGroup.m_n64GroupID bRead:false];
//                ASSERT(item.m_pFileID);
            }
        }
    }
    else if (_m_sMsgType==MSG_NOTICE)
    {
//        _m_aItem.RemoveAll();
        
//        int nCurPos = 0;
//        NSString *strType = l_FindSubString(m_strMsgText, " | ", nCurPos);
//        
//        ASSERT (strType.IsEmpty() == FALSE);
//        
//        if (strType == "DelMsg")
//        {
//            NSString *strNum = m_strMsgText.Mid(nCurPos);
//            int64_t n64GrpMsgID = _atoi64(strNum);
//            
//            if (n64GrpMsgID > 0 && _m_pGroup)
//                _m_pGroup DelMsg: m_pGroup->m_n64GroupID deleid:(int64_t) DelMsg(n64GrpMsgID, _m_n64SenderID);
//        }
//        else if (strType == "ModGrpNick")
//        {
//            if (m_n64GrpMsgID > m_pGroup->m_n64LoginGrpMsgID)		// else Ignore
//            {
//                CString strOldNick = l_FindSubString(m_strMsgText, " | ", nCurPos);
//                CString strNewNick = m_strMsgText.Mid(nCurPos);
//                strNewNick.Replace("||", "|");
//                
//                m_pGroup->ModGrpNickName(m_n64SenderID, strNewNick);
//            }
//        }
//        else if (strType == "ModGrpName")
//        {
//            CString strOld = l_FindSubString(m_strMsgText, " | ", nCurPos);
//            CString strNew = m_strMsgText.Mid(nCurPos);
//            strNew.Replace("||", "|");
//            
//            if (strNew.IsEmpty() == FALSE)
//            {
//                m_aItem.Add(CMsgItem(MSG_ITEM_TEXT, 0, "–ﬁ∏ƒ»∫√˚≥∆Œ™\"" + strNew + "\""));
//                
//                if (m_n64GrpMsgID > m_pGroup->m_n64LoginGrpMsgID)		// else Ignore
//                {
//                    m_pGroup->DoMod(IDM_GROUP_NAME, 0, strNew, FALSE);
//                }
//            }
//        }
//        else if (strType == "ModGrpPortrait")
//        {
//            CString strOld = l_FindSubString(m_strMsgText, " | ", nCurPos);
//            CString strNew = m_strMsgText.Mid(nCurPos);
//            INT64 n64PortraitID = _atoi64(strNew);
//            if (n64PortraitID >= 0)
//            {
//                m_aItem.Add(CMsgItem(MSG_ITEM_TEXT, 0, "–ﬁ∏ƒ¡À»∫Õ∑œÒ"));
//                
//                if (m_n64GrpMsgID > m_pGroup->m_n64LoginGrpMsgID)		// else Ignore
//                {
//                    m_pGroup->DoMod(IDM_GROUP_HEAD, n64PortraitID, "", FALSE);
//                }
//            }
//        }
//        else
//        {
//            ASSERT(FALSE);
//        }
    }
    else if (_m_sMsgType < 0)
    {
//        _m_n64DeleterID = _atoi64(m_strMsgText);
    }
}


- (void)CheckFileID{
    
    
}

- (NSString *)GetShow:(bool)bWantWR{
    
    if (_m_sMsgType < 0)
    {
        if (_m_n64DeleterID > 0)
        {
            return  @"";//获取全局的用户名字 有待实现
//            NSString strNick = l_GetNick(m_n64DeleterID, m_pGroup, 1, bWantWR);
//            
//            if (strNick.IsEmpty())
//                return "≥∑ªÿ¡À“ªÃıœ˚œ¢";
//            else
//                return strNick + "≥∑ªÿ¡À“ªÃıœ˚œ¢";
        }
    }
    else if (_m_sMsgType == MSG_NOTICE)
    {
        if (_m_aItem.count== 1)
        {
            CMsgItem* item = _m_aItem[0];
            if (item.m_cType == MSG_ITEM_TEXT)
            {
                NSString *strNick = @"";
                //l_GetNick(m_n64SenderID, m_pGroup, 1, bWantWR);获取全局的用户名字 有待实现
                
                if (strNick.length == 0)
                    return item.m_strItem;
                else
                    return [strNick  stringByAppendingString: item.m_strItem];
            }else{
                
                NSLog(@"get show error");
            }
        }
    }
    else
    {
        NSString *strMsg = @"";
        if (_m_sMsgType == MSG_TEXT)
            strMsg = [self Item2Show];
        else if (_m_sMsgType == MSG_FILE)
            strMsg = @"[文件]";
        else if (_m_sMsgType == MSG_PIC)
            strMsg = @"[图片";
        
        if (strMsg&& strMsg.length > 0)
        {
            NSString *strNick = @"";
            //l_GetNick(m_n64SenderID, m_pGroup, 1, bWantWR);获取全局的用户名字 有待实现
            
            if (strNick.length == 0)
                return strMsg;
            else
                return [strNick stringByAppendingString:strMsg];
        }
    }
    
    return @"";
}

- (int)Text2Item:(NSString *)strText{
    [_m_aItem removeAllObjects];
    NSString *strMid;
    NSInteger nPosComma = -1;
    NSInteger nPosDot = -1;
    int nType = 0;
    int64_t n64FileID = 0;
    NSRange tempRange = [strText rangeOfString:@"["];
    NSInteger nBeginPos = tempRange.location;
    if(nBeginPos < 0)
    {
        strMid = strText;
        [strMid stringByReplacingOccurrencesOfString:@"[[" withString:@"["];
        [strMid stringByReplacingOccurrencesOfString:@"]]" withString:@"]"];
        CMsgItem *tempMsg = [[CMsgItem alloc] init];
        [tempMsg createMsgItem:MSG_ITEM_TEXT int64:0 strItem:strMid];
        [_m_aItem addObject:tempMsg];
        return 0;
    }
    else if(nBeginPos > 0)
        return -1;
    
    BOOL bOK = FALSE;
    NSInteger nEndPos = 0;
    NSInteger nTextLen = strText.length;
    while(nBeginPos < nTextLen)
    {
        NSRange tempRange = [strText rangeOfString:@"]" options:NSCaseInsensitiveSearch range:NSMakeRange(nBeginPos+1, nTextLen - 1- nBeginPos)];
        nEndPos = tempRange.location;
        if(nEndPos < 0)
            break;
        
        
        NSRange Rangepoint = [strText rangeOfString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(nBeginPos+1, nTextLen - 1- nBeginPos)];
        nPosComma = Rangepoint.location;
//        nPosComma = strDBText.Find(',', nBeginPos+1);
        if(nPosComma < 0 || nPosComma > nEndPos)
            break;
        strMid = [strText substringWithRange:NSMakeRange(nBeginPos +1 ,nPosComma-nBeginPos-1 )];
//        strMid = strText.Mid(nBeginPos+1, nPosComma-nBeginPos-1);
        nType = strMid.intValue;
        if(nType < (int)MSG_ITEM_TEXT || nType > (int)MSG_ITEM_FILE)
            break;
        
        
        strMid = [strText substringWithRange:NSMakeRange(nPosComma +1 ,nEndPos-nPosComma-1 )];
        //strText.Mid(nPosComma+1, nEndPos-nPosComma-1);
        if(strMid&&strMid <=0)
            break;
        [strMid stringByReplacingOccurrencesOfString:@"[[" withString:@"["];
        [strMid stringByReplacingOccurrencesOfString:@"]]" withString:@"]"];
        
        n64FileID = 0;
        if(nType == MSG_ITEM_IMAGE || nType == MSG_ITEM_FILE)
        {
            NSRange tempRange = [strMid rangeOfString:@"."];
            nPosDot = tempRange.location;
            
//            nPosDot = strMid.Find('.');
            if(nPosDot < 0)
                break;
            
            n64FileID = strMid.longLongValue;
            if(n64FileID == 0)
                break;
            
            strMid = [strMid substringFromIndex:nPosDot + 1];
            //strMid.Mid(nPosDot+1);
        }
        CMsgItem *tempMsg = [[CMsgItem alloc] init];
        [tempMsg createMsgItem:nType int64:n64FileID strItem:strMid];
        [_m_aItem addObject:tempMsg];
//        _m_aItem.Add(CMsgItem((BYTE)nType, n64FileID, strMid));
        
        if(nEndPos == nTextLen-1)
        {
            bOK = TRUE;
            break;
        }
        
        NSRange Rangepos = [strText rangeOfString:@"[" options:NSCaseInsensitiveSearch range:NSMakeRange(nBeginPos+1, nEndPos- nBeginPos)];
        nBeginPos = Rangepos.location;
        if(nBeginPos != nEndPos+1)
            break;
    }
    
    if(!bOK)
    {
        [_m_aItem removeAllObjects];
        return -1;
    }
    
    return 0;
}

- (NSString *)Item2Text{
    NSString *strMsgText = [NSMutableString string];
    NSString *str;
    NSString *strItem;
    
    int nNumItem = (int)_m_aItem.count;
    for(int nI = 0; nI < nNumItem; nI++)
    {
        CMsgItem *item = [_m_aItem objectAtIndex:nI];
        
        if (item.m_cType == MSG_ITEM_TEXT && nNumItem == 1)
        {
            str = item.m_strItem;
            [str stringByReplacingOccurrencesOfString:@"[" withString:@"[["];
            [str stringByReplacingOccurrencesOfString:@"]" withString:@"]]"];
            
        }
        else if(item.m_cType == MSG_ITEM_TEXT || item.m_cType == MSG_ITEM_ICON)
        {
            strItem = item.m_strItem;
            [strItem stringByReplacingOccurrencesOfString:@"[" withString:@"[["];
            [strItem stringByReplacingOccurrencesOfString:@"]" withString:@"]]"];
            str =[ NSString stringWithFormat:@"[%d,%@]",item.m_cType, strItem];
        }
        else if(item.m_cType == MSG_ITEM_IMAGE)
        {
            strItem =@"";//获取图片的扩展名称
            //g_Path2Ext(item.m_strItem);
            [strItem stringByReplacingOccurrencesOfString:@"[" withString:@"[["];
            [strItem stringByReplacingOccurrencesOfString:@"]" withString:@"]]"];
//            strItem.Replace("[", "[[");
//            strItem.Replace("]", "]]");
            str =[ NSString stringWithFormat:@"[%d,%lld.%@]",item.m_cType,item.m_n64FileID, strItem];
//            str.Format("[%d,%I64d.%s]", item.m_cType, item.m_n64FileID, strItem);
        }
        else if(item.m_cType == MSG_ITEM_FILE)
        {
            
            strItem =@""; //获取文件名称
            //g_PathName2FileName(item.m_strItem);
            [strItem stringByReplacingOccurrencesOfString:@"[" withString:@"[["];
            [strItem stringByReplacingOccurrencesOfString:@"]" withString:@"]]"];
            str = [NSString stringWithFormat:@"[%d,%lld.%@]", item.m_cType, item.m_n64FileID, strItem];
//            str.Format("[%d,%I64d.%s]", item.m_cType, item.m_n64FileID, strItem);
        }
        else{
            NSLog(@"Item2Text error");
            return nil;
        }
     strMsgText=  [strMsgText stringByAppendingString:str];
    }
    
    return strMsgText;
}

- (NSString *)Item2Show{
    
    return @"";
}
@end


@implementation CGroup

- (id)init{
    self =[super init];
    if (self) {
        self.m_aMsg = [NSMutableArray array];
        self.m_aMember = [NSMutableArray array];
        self.m_aMemberS = [NSMutableArray array];
    }
    return self;
}
- (void)setGroupMessage:(CGroupBase *)baseGroup{
    self.m_n64GroupID = baseGroup.m_n64GroupID;
    self.m_n64PortraitID = baseGroup.m_n64GroupID;
    self.m_dwPermissionFlag = baseGroup.m_dwPermissionFlag;
    self.m_n64Peer_MinMsgID = baseGroup.m_n64Peer_MinMsgID;
    self.m_n64MaxGrpMsgID = baseGroup.m_n64MaxGrpMsgID;
    self.m_dwMaxMsgSeconds = baseGroup.m_dwMaxMsgSeconds;
    self.m_strPeerGrpName = baseGroup.m_strPeerGrpName;
    self.m_strNickName = baseGroup.m_strNickName;
    
    self.m_strPeerRemark = baseGroup.m_strPeerRemark;
    self.m_n64ReadGrpMsgID = baseGroup.m_n64ReadGrpMsgID;
    self.m_strSignature = baseGroup.m_strSignature;
    self.m_nNumGrpMember = baseGroup.m_nNumGrpMember;
    self.m_strCustomerTag = baseGroup.m_strCustomerTag;
}

- (CNewMsg *)searchMsg:(int64_t )n64GroupID{
    for (CNewMsg *temppMsg in self.m_aMsg) {
        if (n64GroupID == temppMsg.m_n64GroupID) {
            return temppMsg;
        }
    }
    return nil;
}

- (void)Read{
    _m_n64MaxMsgID = 0;
    _m_bLoaded = TRUE;
    CBuffer buf;
    buf.m_bSingleRead = true;
    buf.Initialize(4096, true);
    CBuffer bufMsg;
    bufMsg.m_bSingleRead = true;
    bufMsg.Initialize(4096, true);
    NSString *strFile = [NSString stringWithFormat:@"Group%lld",self.m_n64GroupID];
    strFile = [NSString stringWithFormat:@"%@%@",[[EMCommData sharedEMCommData] commFilePath],strFile];
    buf.FileRead(strFile);
    int64_t n64GroupID = self.m_n64GroupID;
    int64_t n64MaxGrpMsgID = _m_n64MaxMsgID;
    int64_t n64RecvMaxID = 0;
    
    if (buf.GetBufferLen() > 0){
        int32_t wVersion = buf.ReadShort();
        if (wVersion >= 3)
            buf.ReadChar();
        
        if (wVersion >= 2)
        /*m_n64ReadGrpMsgID = */buf.ReadLong();
        
        int nMsgSize = buf.ReadInt();
        
        for (int i=0; i<nMsgSize; i++)
        {
            int64_t n64GrpMsgID = buf.ReadLong();
            int nMsgSize = buf.ReadInt();
            if (n64GrpMsgID<=0 || nMsgSize<=0)
                break;
            
            bufMsg.ClearBuffer();
            bufMsg.Write(buf.GetBuffer(buf.m_nReadPos), nMsgSize);
            buf.SkipData(nMsgSize);
            
            CNewMsg* pMsg = [self searchMsg:n64GroupID];
            //self.m_aMsg    _m_aMsg.Find(n64GrpMsgID);
            if (pMsg==NULL){
                pMsg = [[CNewMsg alloc] init];;
                
                if (pMsg==NULL)
                    break;
                
                pMsg.m_pGroup = self;
                pMsg.m_n64GrpMsgID = n64GrpMsgID;
            }
            [pMsg readFile:bufMsg version:wVersion];
//            pMsg->ReadFile(bufMsg, wVersion);
            [self.m_aMsg addObject:pMsg];
            [pMsg AfterRecv];
            [self updateMessage:pMsg addcount:NO];
            if (n64RecvMaxID < n64GrpMsgID)
                n64RecvMaxID = n64GrpMsgID;
        }
           _m_dwUpdateCount++;
    }
}

- (void)Write{
    
    
}

- (CNewMsg *)getMsg:(int64_t)n64GrpMsgID{
    //    m_wr.BeginRead();
    //    CNewMsg* pRet = m_aMsg.Find(n64GrpMsgID);
//    
//    m_wr.EndRead();
//    return pRet;
    return nil;
}

- (CNewMsg *)createMsg:(int64_t)n64GrpMsgID{
    CNewMsg* pRet = [[EMCommData sharedEMCommData] getMsgbyId:n64GrpMsgID];
    if (pRet)
        return pRet;

    pRet =[[CNewMsg alloc] init];
    if (pRet)
    {
        pRet.m_pGroup = self;
        pRet.m_n64GrpMsgID = n64GrpMsgID;
    }
    return pRet;
}

- (void)DelMsg:(int64_t)n64GrpMsgID deleid:(int64_t)n64DelID{
    CNewMsg* pMsg = [self searchMsg:n64GrpMsgID];
    if (pMsg)
    {
        if (pMsg.m_sMsgType > 0)
        {
            pMsg.m_sMsgType = -pMsg.m_sMsgType;
        }
        
        pMsg.m_strMsgText = [NSString stringWithFormat:@"%lld",n64DelID];
        pMsg.m_n64DeleterID = n64DelID;
    }
}

- (bool)updateMessage:(CNewMsg *)pMsg addcount:(bool) addCount{
    if (!pMsg) {
        return  NO;
    }
    BOOL bRet = FALSE;
    
    if (_m_n64MaxMsgID < pMsg.m_n64MsgID)
        _m_n64MaxMsgID = pMsg.m_n64MsgID;
    if (_m_n64MaxMsgID < pMsg.m_n64GrpMsgID)
    {
        if (_m_n64MaxMsgID + 1 < pMsg.m_n64GrpMsgID)
            bRet = TRUE;
        _m_n64MaxMsgID = pMsg.m_n64GrpMsgID;
    }
    if (self.m_dwMaxMsgSeconds < pMsg.m_dwMsgSeconds)
        self.m_dwMaxMsgSeconds = pMsg.m_dwMsgSeconds;
    
    if (addCount)
        _m_dwUpdateCount++;
    
    return bRet;
}

- (void)queryMsg{
    
}

- (CGroupMember *)findMember:(int64_t) n64UserID{
    for( CGroupMember *tempMember in self.m_aMember){
        if (tempMember.m_n64UserID == n64UserID ) {
            return tempMember;
        }
    }
    return nil;
}

- (CGroupMember *)getCustomerInfo{
    return  [[EMCommData sharedEMCommData] getMemberByGroupId:self.m_n64GroupID];
}
- (bool )findMember:(int64_t) n64UserID portraitid:(int64_t &)n64PortraitID strNickName:(NSString *)strNickName bgrpNickName:(bool )bGrpNickName bWantWR:(bool)bWantWR{
    
    return YES;
}

- (void)getShowNameID:(int64_t)n64ShowID strName1:(NSString *)strName1 strName2:(NSString *)strName2{
    
}

- (NSString *)GetTag{
    return self.m_strCustomerTag;
}

- (NSString *)getTagNickName{
    NSString *strRet =@"";
    if(self.m_wGroupType == TYPE_SERVICE)
    {
        if ([self isService])	//±æ’À∫≈ «øÕ∑˛
        {
            int nSize = (int)[_m_aMemberS count] ;
            for (int i=0; i<nSize; i++)
            {
                CGroupMember *member = [_m_aMemberS objectAtIndex:i];
                if ([member isCustomer])	// øÕªß
                {
                    strRet = [member getTagGroupName];
                    break;
                }
            }
        }
    }
    return strRet;
}



- (NSString *)GetEM_UserName{
    
    NSString *strRet =@"";
    if(self.m_wGroupType == TYPE_SERVICE)
    {
        if ([self isService])	//±æ’À∫≈ «øÕ∑˛
        {
            int nSize = (int)[_m_aMemberS count] ;
            for (int i=0; i<nSize; i++)
            {
                CGroupMember *member = [_m_aMemberS objectAtIndex:i];
                if ([member isCustomer])	// øÕªß
                {
                    strRet = member.m_strEM_UserName;
                    break;
                }
            }
        }
    }
    return strRet;
}

- (CGroupMember *)searchGroupMemer:(CGroupMember *)member{
    
    for (CGroupMember *tempGroup in  self.m_aMemberS) {
        if(tempGroup.m_n64UserID == member.m_n64UserID){
            return tempGroup;
        }
    }
    return nil;
}

- (bool)ModGrpNickName:(int64_t)n64UserID strGrpNickName:(NSString *)strGrpNickName{
    if (self.m_wGroupType == TYPE_COUPLE)
        return NO;
    
    CGroupMember *gmFind;
    gmFind.m_n64UserID = n64UserID;

    CGroupMember *tempMember = [self searchGroupMemer:gmFind];
//    if (nPos >= 0)
    if (tempMember) {
            tempMember.m_strMbrNickName = strGrpNickName;
        return YES;
    }
    return NO;
}

- (void)SendModPortrait:(int64_t)n64UserID GroupID:(int64_t) n64GroupID NewPortraitID:(int64_t ) n64NewPortraitID strNewPortraitFile:(NSString *)strNewPortraitFile{
    
}

- (NSString *)GetLastMsgShow{
    NSInteger nSizeMsg = [self.m_aMsg count];//(int)m_aMsg.GetSize();
    if (nSizeMsg > 0){
        for (NSInteger i=nSizeMsg-1; i>=0; i--)
        {
            CNewMsg* pMsg =  [self.m_aMsg objectAtIndex:i];//m_aMsg[i];
            NSString *strMsg = [pMsg GetShow:NO];
            if (!strMsg)
                return strMsg;
        }
    }
    return @"";
}

@end


@implementation CGroupBase

- (Byte )isTopMost{
    if (_m_dwPermissionFlag & 0x800000)
        return 1;
    else
        return 0;
}

- (void)setTopMost:(Byte )cTopMost{
    if (cTopMost)
        _m_dwPermissionFlag |= 0x800000;
    else
        _m_dwPermissionFlag &= (~0x800000);
}

- (bool)isService{
    return (_m_wGroupType != 1 && _m_dwPermissionFlag & 0x08);
}

- (bool)isLord{
    return (_m_wGroupType != 1 && _m_dwPermissionFlag & 0x10);
}

- (bool)isAdmin{
  return (_m_wGroupType != 1 && _m_dwPermissionFlag & 0x18);
    
}

- (bool)canSend{
    return (_m_dwPermissionFlag & 0x02);
}

- (bool)canSendFile{
   return (_m_dwPermissionFlag & 0x04);
}
@end

@implementation CRecvGroupMember
- (id)init{
    self = [super init];
    if (self) {
        self.m_Member = [[CGroupMember alloc] init];
    }
    return self;
}
@end

@implementation CGroupSort
@end

@implementation CQueryMsg


@end

@implementation CMsgItem

- (void)createMsgItem:(Byte )ctype int64:(int64_t)fileId strItem:(NSString *)strItem{
    _m_cType = ctype;
    _m_strItem = strItem;
    _m_n64FileID = fileId;
    _m_dwFileSize = 0;
    _m_pFileID = NULL;
    
}
- (NSString *)getPathName{
    return  @"";
}
- (NSString *)getFileName{
    return @"";
}

@end

@implementation CChatCmd : NSObject

- (id)init{
    self = [super init];
    if (self) {
        _m_n64CmdID = 0;
        _m_dwSeconds = 0;
        _m_wType = 0;
    }
    return self;
}


- (void)clearData{
    _m_n64CmdID = 0;
    _m_dwSeconds = 0;
    _m_wType = 0;
}

- (void)doCmd{
    short wCmdType = _m_wType / 100;
    short wVersion = (_m_wType % 100 + 1) / 2;
    
    Byte *answerbyte = (Byte *)[self.m_Data bytes];
    CBuffer *buf = new CBuffer;
    buf->Initialize(4095,true);
    buf->m_bSingleRead = true;
    buf->Write(answerbyte, self.m_Data.length);
    if (wCmdType == 206){
        int64_t n64ModUserID = buf->ReadLong();
        short wType = buf->ReadShort();
        
        NSString *strText = @"";
        int64_t n64PortraitID = 0;
        
        if (wType == 2)
            n64PortraitID = buf->ReadLong();
        else
            strText = buf->ReadStringShort();
        
        int64_t n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        
        if (n64ModUserID == n64UserID){
            UserInfo *user = [EMCommData sharedEMCommData].selfUserInfo;
            
            if (wType == 1)
                user.m_strNickName = strText;
            else if (wType == 3)
                user.m_strSignature = strText;
            else
                user.m_n64PortraitID = n64PortraitID;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateSelfNoticeMessage object:nil];
            //修改了自己的消息
        }else{
            CGroupMember *gmFind;
            gmFind.m_n64UserID = n64ModUserID;
            NSArray *tempGroupArray = [NSArray arrayWithArray: [[EMCommData sharedEMCommData] getSortGroup]];
            int nSizeGroup = tempGroupArray.count;//(int)theApp.m_aGroup.GetSize();
            for (int i=0; i<nSizeGroup; i++){
                CGroup* pGroup = [tempGroupArray objectAtIndex:i];
                if (pGroup.m_wGroupType == TYPE_COUPLE){
                    if (pGroup.m_n64Peer_MinMsgID == n64ModUserID){
                        if (wType == 1)
                            pGroup.m_strNickName = strText;
                        else if (wType == 3)
                            pGroup.m_strSignature = strText;
                        else
                            pGroup.m_n64PortraitID = n64PortraitID;
                        
                        pGroup.m_dwUpdateCount++;
                        pGroup.m_bWantSave = TRUE;
                        //更新群组
                    }
                }else{
                   CGroupMember *updateMember  = [pGroup findMember:n64ModUserID];
                    if (updateMember){
                        if (wType == 1)
                            updateMember.m_strNickName = strText;
                        else if (wType == 3){
                            int iii = 0;
                        }else
                            updateMember.m_n64PortraitID = n64PortraitID;
                        }
                        pGroup.m_dwUpdateCount++;
                        pGroup.m_bWantSave = TRUE;
                                  //更新群组
                }
            }
        }
    }else if (wCmdType == 211){
        int64_t n64ModUserID = buf->ReadLong();
        int64_t n64ModGroupID = buf->ReadLong();
        short wModType = buf->ReadShort();
        
        NSString *strNewText = @"";
        int64_t n64NewNum = 0;
        
        if (wModType == 1)
            strNewText = buf->ReadStringShort();
        else if (wModType == 2)
            strNewText = buf->ReadString();
        else if (wModType == 3)
            n64NewNum = buf->ReadLong();
        else if (wModType == 4)
            n64NewNum = buf->ReadChar();
        else
            return;
        
        int64_t n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        if (n64ModUserID != n64UserID)
            return;
        
        CGroup* pGroup =  [[EMCommData sharedEMCommData] getGroupbyid:n64ModGroupID];
        if (pGroup == NULL)
            return;
        if (wModType == 1)
            pGroup.m_strPeerRemark = strNewText;
        else if (wModType == 2){
            pGroup.m_strCustomerTag = strNewText;
            ///???UpdateMember?
        }
        else if (wModType == 3){
            pGroup.m_n64ReadGrpMsgID = n64NewNum;
        }
        else{
//            pGroup.SetTopMost((Byte)n64NewNum);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupNotice object:[NSNumber numberWithLongLong:n64ModGroupID]];
        //通知
    }
}

- (int64_t) getSortid{
    return _m_n64CmdID;
}


@end
