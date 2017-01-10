//
//  EMFileData.h
//  EmomeyIM
//  Created by 尤荣荣 on 16/9/19.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Buffer.h"
#import "UserInfo.h"
@interface EMFileData : NSObject{
    Byte m_pcHash[16];
}
@property (nonatomic, assign) Byte *m_pcBuffer;
@property (nonatomic, assign) int32_t m_dwMaxSize;
@property (nonatomic, assign) int32_t m_dwSize;
@property (nonatomic, strong) NSString *descfilePath;
- (Byte *)getpcHash;
- (void)createMd5;
- (void)allocNewSize:(int32_t) dwNewSize;
- (void)readBuffer:(CBuffer * )buffer size:(Byte) dwSize;
- (void)writeBuffer:(CBuffer *)buffer size:(Byte) dwSize;
- (Byte *)getData;
- (NSString *)toString;
- (void)fromString:(NSString *)str;
- (BOOL)readFile:(NSString *)strPathName;
- (BOOL)writeFile:(NSString *)fileName;
- (void)adddata:(Byte *)pcData wSize:(int32_t)dwData;
@end

enum { STATUS_NONE = 0, STATUS_OK, STATUS_ERROR, STATUS_READ, STATUS_SOCK, STATUS_UPLOAD };
@interface EMFileID: NSObject{
    Byte m_pcHash[16];		// MD5
    long m_lUseCount;
}
@property (nonatomic, strong) UIImage *m_pImage;
@property (nonatomic, assign) int64_t m_n64FileID;
@property (nonatomic, assign) Byte m_cType;
@property (nonatomic, strong) NSString *m_strFileName;
@property (nonatomic, assign) int64_t m_n64UserID;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, assign) int32_t m_dwRecvSize;
@property (nonatomic, assign) int32_t m_dwRecvPos;
@property (nonatomic, strong) NSString *m_strRet;
@property (nonatomic, strong) EMFileData *m_Data;
@property (nonatomic, assign) char m_cStatus;
@property (nonatomic, assign) int m_nRet;
@property (nonatomic, assign) char m_cPause;		//暂停
@property (nonatomic, assign) long m_lUseCount;
- (void)readFile;
- (void)writeFile;
- (NSString *)getPathName;
- (void)readFileData;
- (void)checkRead;
- (Byte *)getpcHash;
@end

@interface EMHash2ID : NSObject{
    Byte m_pcHash[16];
}
@property (nonatomic , assign) int64_t m_n64FileID;
- (Byte *)getpcHashvalue;
- (void)updateHasvalu:(Byte *)byte;
- (id)initWithHash:(Byte *)pcHash fileId:(int64_t)n64FileID;
@end

@interface EMFileCenter: NSObject
@property (nonatomic, assign) Byte m_cFileType;
@property (nonatomic, assign) int64_t m_n64FileID;
@property (nonatomic, strong) NSMutableArray <EMFileID *> *m_aFileID;
@property (nonatomic, strong) NSMutableArray <EMFileID *> *m_aFileID2; //临时的，等待发送服务器的
@property (nonatomic, strong) NSMutableArray <EMHash2ID *> *m_aHash2ID;
- (int64_t )getFileid;
- (int64_t)hashID:(Byte *)pcHash;
- (bool)addFileID:(EMFileID *)pFileId;
- (EMFileID *)addFileId:(int64_t)n64FileID strfileName:(NSString *)strFileName fd:(EMFileData *)fd needReWrite:(bool)bOverWrite;
- (EMFileID *)getFileID:(int64_t)n64FileID n64GroupID:(int64_t) n64GroupID bread:(bool) bRead;
@end

@interface EMLoadFile: NSObject
@property (nonatomic, assign) int m_nSizeNow;
@property (nonatomic, assign) int m_nSizeMax;
@property (nonatomic, assign) int m_nTickNow;
@property (nonatomic, assign) int m_nTickMax;
@property (nonatomic, strong) NSMutableArray <EMFileID *>* m_aFileID;
@end
