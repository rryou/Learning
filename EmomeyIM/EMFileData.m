//
//  EMFileData.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/19.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "EMFileData.h"
#import "MD5Coder.h"
#import "EMCommData.h"
#import "CommDataModel.h"
#import "EMTypeConversion.h"
@implementation EMFileData


- (id)init{
    self = [super init];
    if (self) {
        self.m_pcBuffer = (Byte *)malloc(32*1024);
        self.m_dwMaxSize = 32*1024;
        self.m_dwSize = 0;
    }
    return self;
}
- (void)allocNewSize:(int32_t) dwNewSize{
    if (dwNewSize >_m_dwMaxSize) {
        Byte *tempbyte =(Byte *)malloc(_m_dwMaxSize);
        memcpy(tempbyte, _m_pcBuffer, _m_dwMaxSize);
        free(_m_pcBuffer);
        _m_pcBuffer = nil;
        _m_pcBuffer = (Byte *)malloc(dwNewSize);
        memcpy(_m_pcBuffer, tempbyte, _m_dwMaxSize);
        _m_dwMaxSize = dwNewSize;
    }
}

- (void)adddata:(Byte *)pcData wSize:(int32_t)dwData{
    if (dwData == 0) {
        return;
    }
    [self allocNewSize:(_m_dwSize+dwData)];
    if (_m_pcBuffer) {
        memcpy(_m_pcBuffer +_m_dwSize, pcData, dwData);
    }
}

- (void)readBuffer:(CBuffer *)buffer size:(Byte)dwSize{
    _m_dwSize = 0;
    int32_t dwNewSize;
    buffer->Read(&dwNewSize, dwSize);
    [self allocNewSize:dwNewSize];
    if (_m_pcBuffer && _m_dwMaxSize>=dwNewSize){
        _m_dwSize = dwNewSize;
        buffer->Read(_m_pcBuffer, _m_dwSize);
    }
}

- (void)writeBuffer:(CBuffer *)buffer size:(Byte)dwSize{
    if (_m_pcBuffer && _m_dwSize>0){
        buffer->Write(&_m_dwSize, dwSize);
        buffer->Write(_m_pcBuffer, _m_dwSize);
    }
    else{
        int32_t dw0 = 0;
        buffer->Write(&dw0, dwSize);
    }
}

- (void)createMd5{
    memset(m_pcHash, 0, 16);
//    CMD5Coder::EncodeMD5Raw(_m_pcBuffer, _m_dwSize, (char*)m_pcHash);
    NSData *tempData = [NSData dataWithBytes:_m_pcBuffer length:_m_dwSize];
    [EMTypeConversion  createFileMD5:tempData  pcHash:m_pcHash];
}

- (Byte *)getData{
	return _m_pcBuffer;
}

- (void)dealloc{
    free(_m_pcBuffer);
}

- (NSString *)toString{
    NSData *tempData = [[NSData alloc] initWithBytes:[self getData] length:_m_dwSize];
    NSString *tempstr = [[NSString  alloc] initWithData:tempData encoding:NSNonLossyASCIIStringEncoding];
    return tempstr;
}

- (void)fromString:(NSString *)str{
    int32_t dwSize = (int32_t) str.length;
    NSData *tempData = [str dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    Byte *bytelist = (Byte *)[tempData bytes];
    [self adddata:bytelist wSize:dwSize];
    [self createMd5];
}

- (BOOL)readFile:(NSString *)strPathName{
    BOOL bRet = FALSE;
    self.descfilePath = strPathName;
    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:strPathName];
    NSData  *filedata = [fh readDataToEndOfFile];
    int32_t dwLength = (int32_t)[filedata length];
    if (dwLength>0){
        [self allocNewSize:dwLength];
        if (_m_pcBuffer && _m_dwMaxSize>=dwLength)
        {
            memcpy(_m_pcBuffer, [filedata bytes], dwLength);
            _m_dwSize = dwLength;
            bRet = TRUE;
        }
    }
    else{
        bRet = TRUE;
    }
    [self createMd5];
    return bRet;
}

- (BOOL)writeFile:(NSString *)fileName{
    
    BOOL bRet = NO;
    
    if (_m_pcBuffer && _m_dwSize>0){
        NSData *tempData = [[NSData alloc] initWithBytes:_m_pcBuffer length:_m_dwSize];
        [tempData writeToFile:fileName atomically:YES];
        bRet = YES;
    }
    
    return bRet;
}
- (Byte *)getpcHash{
    return self->m_pcHash;
}
@end

@implementation EMFileID

- (void)writeFile{
    if (_m_cType == FT_File)
    {
        NSString *strFileTitle, *strExtName;
        NSString *pathtest =[[EMCommData sharedEMCommData] commFilePath];
        NSFileManager *tempFilemageer =[[NSFileManager alloc]init];
        if (![tempFilemageer fileExistsAtPath:pathtest]) {
            [tempFilemageer createFileAtPath:pathtest contents:nil attributes:nil];
        }
        
        int nNum = 0;
        
        while (TRUE)
        {
            NSString *strFileName;
            if (nNum == 0)
                strFileName = _m_strFileName;
            else if (!strExtName){
                strFileName = [NSString stringWithFormat:@"%@(%d)", strFileTitle,nNum];
            }else{
                strFileName = [NSString stringWithFormat:@"%@(%d).%@", strFileTitle, nNum, strExtName];
            }
            
            NSString *strPathName;
            strPathName = [NSString stringWithFormat:@"%@%d/%@", [[EMCommData sharedEMCommData] commFilePath] , _m_cType, strFileName];
            
//            CFileStatus fs;
//            if (CFile::GetStatus(strPathName, fs))
//                nNum++;
//            else
//            {
//                if (nNum)
//                {
//                    _m_strFileName = strFileName;
//                }
//                break;
//            }
        }
    }
    
    CBuffer buf;
    buf.Initialize(40960, true);
    
    try{
        int32_t wVersion = 1;
        buf.WriteShort(wVersion);
        buf.WriteLong(_m_n64UserID);
        buf.WriteLong(_m_n64GroupID);
        buf.WriteString(_m_strFileName);
        buf.Write(m_pcHash, 16);
        //m_Data.Write(buf);
    }
    catch (...)
    {
    }
    
    NSString *strFileName;
    strFileName = [NSString stringWithFormat:@"%d/%lld.dat", _m_cType , _m_n64FileID];
    NSString *writeFilepath = [NSString stringWithFormat:@"%@/%@",[[EMCommData sharedEMCommData]  commFilePath],strFileName];
    NSFileManager *tempFilemageer =[[NSFileManager alloc]init];
    NSString *tempFileName = [[[EMCommData sharedEMCommData]  commFilePath] stringByAppendingFormat:@"/%d/",_m_cType];
    
    NSString *pathtest =[[EMCommData sharedEMCommData] commFilePath];
    if (![tempFilemageer fileExistsAtPath:pathtest]) {
        [tempFilemageer createDirectoryAtPath:pathtest withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![tempFilemageer fileExistsAtPath:tempFileName]) {
        [tempFilemageer createDirectoryAtPath:tempFileName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    buf.FileWrite(writeFilepath);
    
    NSString *strPathName =[self getPathName];
    [_m_Data writeFile:(strPathName)];
//    NSData *tempImageData =[NSData dataWithBytesNoCopy:_m_Data.m_pcBuffer length:_m_Data.m_dwSize];
//    self.m_pImage = [UIImage imageWithData:tempImageData];
    if (_m_cType == FT_Portrait || _m_cType == FT_Pic)
    {
        if (_m_pImage == NULL)
        {
            _m_pImage = [UIImage imageWithContentsOfFile:strPathName];
//            _m_pImage = g_Str2Image(strPathName);
//            ASSERT(m_pImage);
        }
    }
}

- (void)readFile{
    if (_m_cType == FT_Portrait && _m_n64FileID < 10000)
    {
        _m_cStatus = STATUS_OK;
    }
    else
    {
        CBuffer buf;
        buf.m_bSingleRead = true;
        buf.Initialize(4096, true);
        
        NSString *strFileName = [NSString stringWithFormat:@"%d/%lld.dat", _m_cType, _m_n64FileID];
        // 文件目录
        buf.FileRead(strFileName);
        
        if (buf.GetBufferLen()==0)
        {
            _m_cStatus = STATUS_ERROR;
            return;
        }
        int32_t wVersion = buf.ReadShort();
        
        _m_n64UserID = buf.ReadLong();
        _m_n64GroupID = buf.ReadLong();
        _m_strFileName = buf.ReadString();
        buf.Read(m_pcHash, 16);
        
        _m_cStatus = STATUS_OK;
        [_m_Data readFile:[self getPathName]];
        [_m_Data createMd5];
        
        if (memcmp(m_pcHash, [_m_Data getpcHash], 16))
        {
            _m_cStatus = STATUS_ERROR;
        }
    }
    if (_m_cStatus == STATUS_OK)
    {
        if (_m_cType == FT_Portrait || _m_cType == FT_Pic)
        {
            if (_m_pImage == NULL)
            {
//                m_pImage = g_Str2Image(GetPathName());
//                ASSERT(m_pImage);
            }
        }
    }
}

- (void)readFileData{
    [_m_Data readFile:[self getPathName]];
}

- (NSString *)getPathName{
    
    
    NSString *tempStr ;
    if (_m_cType ==FT_Portrait && _m_n64FileID < 10000){
        tempStr = [NSString stringWithFormat:@"%lld.png",_m_n64FileID];
        return  [NSString stringWithFormat:@"%@%@",[[EMCommData sharedEMCommData] commFilePath], tempStr];
    }
    
    if (_m_strFileName)
    {
        tempStr = [NSString stringWithFormat:@"%d/%lld.%@",_m_cType, _m_n64FileID,_m_strFileName];
    }
    else
    {
        if (_m_cType == FT_Portrait)
            tempStr = [NSString stringWithFormat:@"%d/%lld.%@", _m_cType, _m_n64FileID - 10000, _m_strFileName];
        else if (_m_cType == FT_Pic)
             tempStr = [NSString stringWithFormat:@"%d/%lld.%@", _m_cType, _m_n64FileID, _m_strFileName];
        else
            tempStr = [NSString stringWithFormat:@"%d/%@",_m_cType,_m_strFileName];
    }
    
    return [NSString stringWithFormat:@"%@/%@",[[EMCommData sharedEMCommData] commFilePath],tempStr];
}

- (Byte *)getpcHash{
    return self->m_pcHash;
}

- (void)checkRead{
    if (_m_cStatus == STATUS_NONE || _m_cStatus == STATUS_ERROR){
        if (_m_cType == FT_Portrait)
        {
            [self readFile];
            if (_m_cStatus == STATUS_NONE || _m_cStatus == STATUS_ERROR){
                if ([[EMCommData sharedEMCommData] isLogined]){
                    CIM_DownloadData* pData = [[CIM_DownloadData alloc] init];
                    if (pData)
                    {
                        pData.m_cFileType = _m_cType;
                        pData.m_n64UserID = [[EMCommData sharedEMCommData] getUserId];
                        pData.m_n64GroupID = _m_n64GroupID;
                        pData.m_n64FileID = _m_n64FileID;
                        
                        pData.m_pFileID = [self copy];
                        _m_cStatus =STATUS_SOCK;
                    }
                }
                else{
                    _m_nRet = 1;
                    _m_cStatus =STATUS_ERROR;
                }
            }
        }
        else{
            _m_cStatus = STATUS_READ;
        }
    }
    
}

@end

@implementation EMHash2ID

- (void)updateHasvalu:(Byte *)byte{
    if (byte) {
         memcpy(self->m_pcHash, byte, 16);
    }
}

- (id)initWithHash:(Byte *)pcHash fileId:(int64_t)n64FileID{
    self = [super init];
    if (self) {
        if (pcHash) {
            memcpy(self->m_pcHash, pcHash, 16);
            self ->_m_n64FileID = n64FileID;
        }
    }
    return self;
}

- (Byte *)getpcHashvalue{
    return self->m_pcHash;
}

@end

@implementation EMFileCenter
- (EMFileID *)searchFilid:(int64_t )n64FileID{
    if (n64FileID >0) {
        for (EMFileID *tempFile in self.m_aFileID) {
            if (tempFile.m_n64FileID ==n64FileID) {
                return tempFile;
            }
        }
    }
    return nil;
}

- (int64_t)hashID:(Byte *)pcHash{
    //寻找Hash的值。
    EMHash2ID *tempHash = [[EMHash2ID alloc ]initWithHash:pcHash fileId:0];
    NSData *hashData  = [[NSData alloc] initWithBytes:pcHash length:16];
    for (EMHash2ID *tempHash in  _m_aHash2ID) {
        NSData *tempdata = [[NSData alloc] initWithBytes:[tempHash getpcHashvalue] length:16];
        if ([hashData isEqual:tempHash]) {
            return tempHash.m_n64FileID;
        }
    }
    return tempHash.m_n64FileID;
}

- (EMFileID *)searchFilid2:(int64_t )n64FileID{
    if (n64FileID >0) {
        for (EMFileID *tempFile in self.m_aFileID2) {
            if (tempFile.m_n64FileID ==n64FileID) {
                return tempFile;
            }
        }
    }
    return nil;
}

- (EMFileID *)addFileId:(int64_t)n64FileID strfileName:(NSString *)strFileName fd:(EMFileData *)fd needReWrite:(bool)bOverWrite{
    if (n64FileID == 0)
        return NULL;
    EMFileID* pFileID ;
    if (n64FileID > 0)
        pFileID = [self searchFilid:n64FileID];
    else
        pFileID =  [self searchFilid2: n64FileID];
    
    if (pFileID){
        if (bOverWrite)
        {
            ///??? WR
            pFileID.m_strFileName = strFileName;
            pFileID.m_Data = fd;
            memcpy([pFileID getpcHash], [fd  getpcHash], 16);
            
            if (n64FileID > 0)
                pFileID.m_cStatus =STATUS_OK;
            else
                pFileID.m_cStatus = STATUS_UPLOAD;
            [self updateEMFileId:[[EMHash2ID alloc] initWithHash:[pFileID getpcHash] fileId:pFileID.m_n64FileID]];
        }
    }
    if (pFileID)
        return pFileID;
        if (n64FileID > 0)
            pFileID = [self searchFilid:n64FileID];
        else
            pFileID = [self searchFilid2:n64FileID];
        
        if (pFileID){

            if (bOverWrite)
            {
                pFileID.m_strFileName = strFileName;
                pFileID.m_Data = fd;
                memcpy([pFileID getpcHash], [fd getpcHash], 16);
                if (n64FileID > 0)
                    pFileID.m_cStatus = STATUS_OK;
                else
                    pFileID.m_cStatus = STATUS_UPLOAD;
                [self updateEMFileId:[[EMHash2ID alloc] initWithHash:[pFileID getpcHash] fileId:pFileID.m_n64FileID]];
            }
        }
        else
        {
            pFileID = [[EMFileID alloc] init];
            if (pFileID)
            {
                pFileID.m_cType = _m_cFileType;
                pFileID.m_n64FileID = n64FileID;
                
                pFileID.m_strFileName = strFileName;
                pFileID.m_Data = fd;
                memcpy([pFileID getpcHash], [fd getpcHash], 16);
                
                if (n64FileID > 0)
                {
                    if (bOverWrite)
                    {
                        pFileID.m_cStatus = STATUS_OK;
                        [pFileID writeFile];
                    }
                    [_m_aFileID addObject:pFileID];
                }
                else
                {
                    pFileID.m_cStatus =STATUS_UPLOAD;
                    [_m_aFileID2 addObject:pFileID];
                }
                [self updateEMFileId: [[EMHash2ID alloc] initWithHash:[pFileID getpcHash] fileId:pFileID.m_n64FileID]];
            }
        }
    
    return pFileID;
}

- (void)updateEMFileId:(EMHash2ID *)hashId{
    bool findFileid = NO;
    for (EMHash2ID *tempHashId in self.m_aHash2ID) {
        if (tempHashId.m_n64FileID == hashId.m_n64FileID ) {
            [tempHashId updateHasvalu:[hashId getpcHashvalue] ];
            findFileid = YES;
            break;
        }
    }
    if (!findFileid) {
        [self.m_aHash2ID addObject:hashId];
    }
}

- (bool)addFileID:(EMFileID *)pFileId{
    if (pFileId) {
        [_m_aFileID addObject:pFileId];
        [_m_aHash2ID addObject:[[EMHash2ID alloc]  initWithHash:[pFileId  getpcHash] fileId:pFileId.m_n64FileID]];
        return YES;
    }
    return NO;
}

- (EMFileID *)getFileID:(int64_t)n64FileID n64GroupID:(int64_t) n64GroupID bread:(bool) bRead{
    if (_m_cFileType == 0)
        int iii = 0;
    EMFileID* pFileID;
    pFileID = [self searchFilid:n64FileID];
    if (pFileID){
        if (bRead){
            [pFileID checkRead];
            if (pFileID.m_cStatus == STATUS_OK){
                [_m_aHash2ID addObject:[[EMHash2ID alloc] initWithHash:[pFileID getpcHash] fileId:pFileID.m_n64FileID]];
            }
        }
    }
    
    if (pFileID)
        return pFileID;
    if (!pFileID){
        pFileID = [[EMFileID alloc] init];
        if (pFileID){
            pFileID.m_cType = _m_cFileType;
            pFileID.m_n64FileID = n64FileID;
            if (bRead){
                [pFileID checkRead];
                if (pFileID.m_cStatus == STATUS_OK){
                    [_m_aHash2ID addObject:[[EMHash2ID alloc]  initWithHash:[pFileID  getpcHash] fileId:pFileID.m_n64FileID]];
                }
            }
            [_m_aFileID addObject:pFileID];
        }
    }
    return pFileID;
}
@end

@implementation EMLoadFile

@end
