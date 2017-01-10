//
//  EMCommData.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/2.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "EMCommData.h"
#import "CMassGroup.h"

#define kFundDirectoryComponent @"DownLoad/"
#define KMessageNeedUpdate @"MESSAGENEEDUPDATE"
#define kCacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject]
#define kFundDirectory  [kCacheDirectory stringByAppendingPathComponent:kFundDirectoryComponent]
@interface EMCommData(){
    
}
@property (nonatomic, strong) NSDictionary *emojiDict;
@property (nonatomic, strong) NSMutableArray <CGroup *> *groupList;
@property (nonatomic, strong) NSMutableArray <CGroup *> *sortgroupList;
@property (nonatomic, strong) NSMutableArray <CNewMsg *> *messagelist;
@property (nonatomic, strong) NSMutableDictionary *messageSeperatByGroup;
@property (nonatomic, strong) NSMutableArray <CMassGroup *> *massGrouplist;
@property (nonatomic, strong) NSMutableArray <CGroupMember *> *memeberlist;
@property (nonatomic, strong) NSMutableArray <CQueryMsg *>*QueryMsglist;
@property (nonatomic, strong) NSMutableArray *filedataList;
@property (nonatomic, assign) BOOL islogin;
@property (nonatomic, strong) NSMutableDictionary *m_pFC;
@end

@implementation EMCommData
static EMCommData *sharedEMCommData = nil;
+(EMCommData *)sharedEMCommData{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedEMCommData  = [[self alloc] init];
    });
    return sharedEMCommData;
}

- (void)setAccountLoginStatus:(BOOL) login{
    self.islogin = login;
}

- (void)clearAlldata{
    [self.groupList removeAllObjects];
    [self.sortgroupList removeAllObjects];
    [self.memeberlist removeAllObjects];
    [self.massGrouplist removeAllObjects];
    [self.memeberlist removeAllObjects];
    [self.QueryMsglist removeAllObjects];
    self.islogin = NO;
}

- (id)init{
    self = [super init];
    if (self) {
        self->xorTable = (Byte *)malloc(1000);
        self.selfUserInfo = [[UserInfo alloc] init];
        self.groupList = [NSMutableArray array];
        self.messagelist = [NSMutableArray array];
        self.memeberlist = [NSMutableArray array];
        self.filedataList = [NSMutableArray array];
        self.massGrouplist = [NSMutableArray array];
        self.messageSeperatByGroup = [NSMutableDictionary dictionary];
        self->puserKey = (Byte *)malloc(1000);
        self->bBits = 0;
        self->pcounter = (Byte *)malloc(16);
        NSString *pickListPath = [[NSBundle mainBundle] pathForResource:@"PhizPickList" ofType:@"plist"];
       self.emojiDict = [NSDictionary dictionaryWithContentsOfFile:pickListPath];
    }
    return self;
}

- (int64_t)getUserId{
    return self.selfUserInfo.m_n64AccountID;
}

- (void)updateMassGroup:(CMassGroup *)massGroup{
    bool hasUpdate = NO;
    for (CMassGroup *tempGroup in  self.massGrouplist ) {
        if (tempGroup.m_n64BatGroupID == massGroup.m_n64BatGroupID ) {
            tempGroup.m_aGroupID = [NSMutableArray arrayWithArray:massGroup.m_aGroupID];
            tempGroup.m_strName = massGroup.m_strName;
            hasUpdate = YES;
            break;
        }
    }
    if (!hasUpdate) {
        [self.massGrouplist addObject:massGroup];
    }
}

- (NSDate *)commonSinceDate{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:@"2010-01-01 00:00:00"];
}

- (void)updateGroup:(CGroup *)massGroup{
    bool hasUpdate = NO;
    for (CGroup *tempGroup in  self.groupList ) {
        if (tempGroup.m_n64GroupID == massGroup.m_n64GroupID ) {
            tempGroup.m_strPeerRemark = massGroup.m_strPeerRemark;
            hasUpdate = YES;
            break;
        }
    }
    if (!hasUpdate) {
        [self.groupList addObject:massGroup];
    }
}

- (void)updateMemberInfo:(CGroupMember *)newMember{
    bool hasUpdate = NO;
    for (CGroupMember *tempmember in  self.memeberlist ) {
        if (tempmember.m_n64UserID == newMember.m_n64UserID ) {
            tempmember.Gm_strPeerRemark = newMember.Gm_strPeerRemark;
            hasUpdate = YES;
            break;
        }
    }
    if (!hasUpdate) {
        [self.memeberlist addObject:newMember];
    }
}


- (void)deleteMassGroup:(int64_t )massGroupId{
    for (CMassGroup *tempGroup in  self.massGrouplist ) {
        if (tempGroup.m_n64BatGroupID == massGroupId ) {
            [self.massGrouplist removeObject:tempGroup];
            return;
        }
    }
}

- (bool)setMassGroup:(NSMutableArray *)massGrouparray{
    if (self.massGrouplist) {
        [self.massGrouplist removeAllObjects];
    }else{
        self.massGrouplist = [NSMutableArray array];
    }
    [self.massGrouplist addObjectsFromArray:massGrouparray];
    return YES;
}

-(NSArray *)getMassGroup{
    return [NSArray arrayWithArray:self.massGrouplist];
}

- (CNewMsg *)getMsgbyId:(NSInteger) messageID{
    for (CNewMsg *tempmessage in self.messagelist) {
        if (tempmessage.m_n64GrpMsgID == messageID) {
            return tempmessage;
        }
    }
    return nil;
}

- (NSDictionary *)getemojiDict{
    return self.emojiDict;
}

- (bool) haveServiceGroup{
    bool bRet = NO;
    @synchronized (self.groupList) {
        for (int i = 0; i < self.groupList.count; i++) {
            CGroup *tempGroup = [self.groupList objectAtIndex:i];
            if (tempGroup &&tempGroup.m_wGroupType == 3&& tempGroup.isService) {
                bRet = YES;
                break;
            }else{
                continue;
            }
        }
    }
    return bRet;
}

- (NSArray *)getTabGroups:(NSArray *)tabArray{
    NSString *lastSubstr;
    NSMutableArray *lastGroupArray = [NSMutableArray array];
    for(CGroup *tempgroup in self.groupList){
        NSString *custromerTag = [tempgroup.m_strCustomerTag stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *tempTag = [custromerTag componentsSeparatedByString:@"|"];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(SELF IN %@)",tabArray];
        NSArray * filter = [tempTag filteredArrayUsingPredicate:filterPredicate];
        
        if (filter.count > 0) {
            [lastGroupArray addObject:tempgroup];
//            if (![lastGroupArray containsObject:[tempgroup getTagNickName]]) {
//                [lastGroupArray addObject:[tempgroup getTagNickName]];
//            }
        }
    }
//    lastSubstr = [lastGroupArray componentsJoinedByString:@";" ];
//    lastSubstr = [lastSubstr stringByReplacingOccurrencesOfString:@";" withString:@";  "];
//    return lastSubstr;
    return lastGroupArray;
}

- (bool) haveSendGroup:(int64_t)n64GroupID{
    bool bRet = NO;
    @synchronized (self.groupList) {
        for (int i = 0; i < self.groupList.count; i++) {
            CGroup *tempGroup = [self.groupList objectAtIndex:i];
            if (tempGroup &&tempGroup.canSend&&tempGroup.m_n64GroupID !=n64GroupID) {
                bRet = YES;
                break;
            }else{
                continue;
            }
        }
    }
    return bRet;
}

- (bool) haveSendFileGroup:(int64_t)n64GroupID{
    bool bRet = NO;
    @synchronized (self.groupList) {
        for (int i = 0; i < self.groupList.count; i++) {
            CGroup *tempGroup = [self.groupList objectAtIndex:i];
            if (tempGroup &&tempGroup.canSendFile&&tempGroup.m_n64GroupID !=n64GroupID) {
                bRet = YES;
                break;
            }else{
                continue;
            }
        }
    }
    return bRet;
}

- (bool) isLogined{
    return self.islogin;
}

- (void)addNewMsg:(CNewMsg *)newMessage needNotice:(bool)needNotice{
    [self.messagelist addObject:newMessage];
    NSMutableArray *temparray = [self.messageSeperatByGroup objectForKey:[NSNumber numberWithLongLong:newMessage.m_n64GroupID]];
    if (temparray) {
        [temparray addObject:newMessage];
    }else{
        temparray = [NSMutableArray array];
        [temparray addObject:newMessage];
        [self.messageSeperatByGroup  setObject:temparray forKey:[NSNumber numberWithLongLong:newMessage.m_n64GroupID]];
    }
    if (needNotice) {
        [self updateGroupUnReadCount:newMessage.m_n64GroupID];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFIMESSAGEUPDATEMESSAGE object:[NSNumber numberWithLongLong:newMessage.m_n64GroupID]];
    }
}
- (void)updateGroupUnReadCount:(int64_t)grouid{
    CGroup *tempGroup =[self getGroupbyid:grouid];
    tempGroup.unReadCount++;
}

- (void)reSetGroupUnReadCount:(int64_t)grouid{
    CGroup *tempGroup =[self getGroupbyid:grouid];
    tempGroup.unReadCount = 0;
}

- (NSArray *)getGroupList{
    return [NSArray arrayWithArray:self.groupList];
}

- (NSArray *)getSortGroup{
    return [NSArray arrayWithArray:self.groupList];
}

- (NSArray *)getGroupMember{
    return [NSArray arrayWithArray:self.memeberlist];
}

- (NSArray *)getMembersEecept:(NSArray *)exceptedGroupid{
    NSMutableArray *lastMemberlist = [NSMutableArray array];
    for (CGroupMember *tempGroupMember in self.memeberlist ) {
        if ([exceptedGroupid containsObject:[NSNumber numberWithLongLong:tempGroupMember.m_n64GroupID]]) {
            continue;
        }else{
            [lastMemberlist addObject:tempGroupMember];
        }
    }
    return lastMemberlist;
}

- (NSArray *)getLimitMessagsByGroupId:(int64_t) n_GroupId  maxCount:(NSInteger )maxcount;{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self getMessageListByGroupId:n_GroupId]];
    if (maxcount >=tempArray.count) {
        return tempArray;
    }else{
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:maxcount];
        for (NSInteger i = tempArray.count - maxcount ; i <tempArray.count ; i++) {
            [resultArray addObject:[tempArray objectAtIndex:i]];
        }
        return  resultArray;
    }
}

- (NSArray *)getMessageListByGroupId:(int64_t) n_GroupID{
    NSMutableArray *tempArray = [self.messageSeperatByGroup objectForKey:[NSNumber numberWithLongLong:n_GroupID]];
    if (tempArray ) {
        [tempArray sortUsingComparator:^NSComparisonResult(CNewMsg *obj1, CNewMsg *obj2) {
            return [obj1 m_dwMsgSeconds]  <= [obj2 m_dwMsgSeconds]? NSOrderedAscending : NSOrderedDescending;
        }];
        return [[NSArray alloc] initWithArray:tempArray];
    }else{
        return nil;
    }
}

- (NSArray *)getNewMessageListByGroupId:(int64_t) n_GroupID afterMsgid:(int64_t)maxMsgid{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self getMessageListByGroupId:n_GroupID]];
    NSMutableArray *sortArray =[NSMutableArray array];
    for (CNewMsg *tempMsg in tempArray) {
        if (tempMsg.m_n64GrpMsgID >maxMsgid) {
            [sortArray addObject:tempMsg];
        }
    }
    [sortArray sortUsingComparator:^NSComparisonResult(CNewMsg *obj1, CNewMsg *obj2) {
        return [obj1 m_dwExprSeconds]  <= [obj2 m_dwExprSeconds]? NSOrderedAscending : NSOrderedDescending;;
    }];
    return [[NSArray alloc] initWithArray:sortArray];
}

- (NSArray *)getMoreMessageListByGroupId:(int64_t) n_GroupID beforeMsgid:(int64_t)maxMsgid{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self getMessageListByGroupId:n_GroupID]];
    NSMutableArray *sortArray =[NSMutableArray array];
    for (CNewMsg *tempMsg in tempArray) {
        if (tempMsg.m_n64GrpMsgID <maxMsgid) {
            [sortArray addObject:tempMsg];
        }
    }
    [sortArray sortUsingComparator:^NSComparisonResult(CNewMsg *obj1, CNewMsg *obj2) {
        return [obj1 m_dwExprSeconds]  <= [obj2 m_dwExprSeconds]? NSOrderedAscending : NSOrderedDescending;;
    }];
    return [[NSArray alloc] initWithArray:sortArray];
}

- (NSArray *)getMoreLimitMessageListByGroupId:(int64_t) n_GroupID beforeMsgid:(int64_t)maxMsgid limitedNumber:(NSInteger )maxNumber{
    NSArray *tempArray =[self getMoreMessageListByGroupId:n_GroupID beforeMsgid:maxMsgid];
    if (maxNumber >=tempArray.count) {
        return tempArray;
    }else{
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:maxNumber];
        for (NSInteger i = tempArray.count - maxNumber ; i <tempArray.count ; i++) {
            [resultArray addObject:[tempArray objectAtIndex:i]];
        }
        return  resultArray;
    }
}

- (NSArray *)getMessagelist{
    return [NSArray arrayWithArray:self.messagelist];
}

- (NSArray *)getQuerayMsg{
    return [NSArray arrayWithArray:self.QueryMsglist];
}

- (void)addNewGroup:(CGroup *)newGroup{
    [self.groupList addObject:newGroup];
}

- (void)addNewMember:(CGroupMember  *)newMember{
    [self.memeberlist addObject:newMember];
}

- (CGroupMember *)getMemberByGroupId:(int64_t )grouid{
    for (CGroupMember *tempMember in self.memeberlist) {
        if (tempMember.m_n64GroupID == grouid) {
            return  tempMember;
        }
    }
    return nil;
}

- (CGroup *)getGroupbyid:(NSInteger) groupid{
    for (CGroup * tempGroup in self.groupList) {
        if (tempGroup.m_n64GroupID == groupid) {
            return tempGroup;
        }
    }
    return nil;
}

- (void)setGroupMe:(NSArray<CRecvGroupMember *> *)aMember{
    NSMutableArray *aGroupID =[NSMutableArray  array];
    for (int i =0 ; i < aMember.count; i ++) {
        CRecvGroupMember *rgm = aMember[i];
        CGroup *pGroup = [self getGroupbyid: rgm.m_n64GroupID];
        if (!pGroup)
            continue;
        
        if (![aGroupID containsObject:[NSNumber numberWithLongLong: rgm.m_n64GroupID]])
        {
            [pGroup.m_aMember  removeAllObjects];
            [pGroup.m_aMemberS removeAllObjects];
            [aGroupID addObject:[NSNumber numberWithLongLong:rgm.m_n64GroupID]];
        }
        CGroupMember *gm =  rgm.m_Member;
        gm.m_n64GroupID = rgm.m_n64GroupID;
        gm.Gm_strPeerRemark = pGroup.m_strPeerRemark;
        if (rgm.m_cSelf ==1){
            gm.m_n64UserID = self.selfUserInfo.m_n64AccountID;
            gm.m_n64PortraitID = self.selfUserInfo.m_n64PortraitID;
            gm.m_strNickName = self.selfUserInfo.m_strNickName;
            if (pGroup.m_wGroupType == TYPE_SERVICE){
                pGroup.m_strCustomerTag = gm.m_strTag;
            }
        }else{
            [self addNewMember:gm];
        }
        [pGroup.m_aMember addObject:gm];
        [pGroup.m_aMemberS addObject:gm];
    }
    [self reSetGroupData];
}

- (void)reSetGroupData{
    @synchronized (self.groupList) {
        for (CGroup *tempGroup in self.groupList) {
            if (tempGroup.m_aMember.count >2) {
                tempGroup.m_MutilpGroup = YES;
            }else{
                tempGroup.m_MutilpGroup = NO;
            }
        }
    }
}

- (void)addUserFileData:(EMFileData *)fileData{
    
}

- (EMFileData *)getFileDataMessage{
    EMFileData *fileData = [[EMFileData alloc] init];
    return fileData;
}

- (EMFileID *)addFileid:(Byte)fileType n64FileId:(int64_t ) n64FileId strFileName:(NSString *)strFileName mData:(EMFileData *)m_data boverWrite:(bool) boverWrirte{
    if (fileType>= 10) return nil;
    EMFileCenter *tempArray = [self.m_pFC objectForKey:[NSNumber numberWithUnsignedChar:fileType]];
    if (tempArray) {
        return [tempArray addFileId:n64FileId strfileName:strFileName fd:m_data needReWrite:boverWrirte];
    }else{
        tempArray = [[EMFileCenter alloc] init];
      return [tempArray addFileId:n64FileId strfileName:strFileName fd:m_data needReWrite:boverWrirte];
    }
    return nil;
}

- (bool)addfileId:(EMFileID *)pfileID{
    if (pfileID) {
        if (pfileID.m_cType >0) {
            return NO;
        }else{
            EMFileCenter *tempArray = [self.m_pFC  objectForKey:[NSNumber numberWithUnsignedChar:pfileID.m_cType]];
            if (tempArray) {
                [tempArray addFileID:pfileID];
            }else{
                EMFileCenter *tempArray = [[EMFileCenter alloc] init];
                [tempArray addFileID:pfileID];
                [self.m_pFC setObject:tempArray forKey:[NSNumber numberWithUnsignedChar:pfileID.m_cType]];
            }
        }
    }
    return NO;
}

- (EMFileID *)getFileid:(Byte)fileType n64FileId:(int64_t) n64FileId n64GroupID:(int64_t) n64GroupId bRead:(bool)bRead{
    if(fileType >=10) return nil;
    EMFileCenter *fileCenter = [self.m_pFC objectForKey:[NSNumber numberWithUnsignedChar:fileType]];
    if (fileCenter) {
       return [fileCenter getFileID:n64FileId n64GroupID:n64GroupId bread:bRead];
    }else{
        return nil;
    }
}

- (int64_t)hashID:(Byte)cFileType pcHash:(Byte *)pcHash{
    if (cFileType >=10) {
        return 0;
    }
    EMFileCenter *tempCentre =[self.m_pFC objectForKey:[NSNumber numberWithUnsignedChar:cFileType]];
    return [tempCentre hashID:pcHash];
}

- (void)addHash2ID:(Byte) cFileType hash2id:(EMHash2ID *)hashId{
    if (cFileType >=10) {
        return ;
    }
    EMFileCenter *tempCentre =[self.m_pFC objectForKey:[NSNumber numberWithUnsignedChar:cFileType]];
    [tempCentre.m_aHash2ID addObject:hashId];
}

- (int64_t)getFileId:(Byte) cFileType{
    if (cFileType >=10) {
        return  0;
    }
    EMFileCenter *tempCentre =[self.m_pFC objectForKey:[NSNumber numberWithUnsignedChar:cFileType]];
   return [tempCentre getFileid];
}

- (NSString *)commFilePath{
    return  kFundDirectory;
}

- (bool)filehasload:(CMsgItem *)fileValue{
    NSFileManager *tempFileManager = [[NSFileManager alloc] init];
    NSMutableString *tempfilePath = [NSMutableString stringWithString:[[EMCommData sharedEMCommData] commFilePath]];
    [tempfilePath appendFormat:@"/%d/%@",fileValue.m_cType,[NSString stringWithFormat:@"%lld.%@",fileValue.m_n64FileID,fileValue.m_strItem]];
    return [tempFileManager fileExistsAtPath:tempfilePath];
}
//icon特殊
- (bool)imagehasload:(NSString *)fileId{
    if (fileId.longLongValue < 10000) {
        return YES;
    }
    NSFileManager *tempFileManager = [[NSFileManager alloc] init];
    NSMutableString *tempfilePath = [NSMutableString stringWithString:[[EMCommData sharedEMCommData] commFilePath]];
    [tempfilePath appendFormat:@"/2/%@",[NSString stringWithFormat:@"%lld.%@",fileId.longLongValue,@"png"]];
    return [tempFileManager fileExistsAtPath:tempfilePath];
}

- (UIImage *)getlocalImage:(NSString *)fileId{
    if(fileId.longLongValue < 10000){
      return [UIImage imageNamed:fileId];
    }
    
    if ([self imagehasload:fileId]) {
        NSMutableString *tempfilePath = [NSMutableString stringWithString:[[EMCommData sharedEMCommData] commFilePath]];
        [tempfilePath appendFormat:@"/2/%@",[NSString stringWithFormat:@"%lld.%@",fileId.longLongValue,@"png"]];
        return  [UIImage imageWithContentsOfFile:tempfilePath];
    }else{
        return nil;
    }
}

- (UIImage *)getlocalFile:(CMsgItem *)fileValue{
    if ([self filehasload:fileValue]) {
        NSMutableString *tempfilePath = [NSMutableString stringWithString:[[EMCommData sharedEMCommData] commFilePath]];
       [tempfilePath appendFormat:@"/%d/%@",fileValue.m_cType,[NSString stringWithFormat:@"%lld.%@",fileValue.m_n64FileID,fileValue.m_strItem]];
        return  [UIImage imageWithContentsOfFile:tempfilePath];
    }else{
        return nil;
    }
}

@end

