//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHead.h"
#import "Buffer.h"
#import "Compress.h"
#import "EMSocketextend.h"
#import "EMDataPackCoder.h"
enum { WantNone = 0, WantSend, WantRecv, WantAll, WantDelete, WantSendDelete };

typedef void (^ SocketManagerBlock) (NSData *responseData, BOOL success);
typedef void (^ SocketDownImages) (UIImage *newImage, BOOL success);
@interface HandleDataModel : NSObject <EMSocketextendDelegate>{
    CDataHead *m_head;
    CCompress *compress;
    CBuffer *compressbuffer;
}
@property (nonatomic, assign) short m_wStatus;
@property (nonatomic, assign) short m_wVersion;
@property (nonatomic, assign) short m_wPriority;
@property (nonatomic, strong) NSDate *m_dwLastSendTime;
@property (nonatomic, assign) Byte  m_cCodeAlgorithm;
@property (nonatomic, assign) short s_wDefaultPriority;
@property (nonatomic, assign) int32_t m_dwSendBytes;
@property (nonatomic, assign) int32_t m_dwSendBytesLast;
@property (nonatomic, assign) int32_t m_dwSendBytesStat;
- (void) sendSockData:(CBuffer &)buffer;
- (void) recvSockData:(CDataHead &) head sendbuffer:(CBuffer &)buffer;
- (void)sendHead:(CBuffer &)buffer dataType:(short) wDataType;
- (void)sendSockPost;
@property (nonatomic, copy) SocketManagerBlock completionBlock;
@end

@interface CCompressSockData : HandleDataModel
@property (nonatomic, assign) int32_t s_n64CompIn;
@property (nonatomic, assign) int32_t s_n64CompOut;
- (bool)recvCompressData:(CBuffer &)buffer;
- (bool)recvCompressData2:(CBuffer &)buffer;
- (bool)sendCompressData:(CBuffer &)buffer;
- (CBuffer *)getCompress;
- (void)compress2Buf:(CBuffer &)buffer wDataType:(short) wDataType;
- (void)compressACK2Buf:(CBuffer &)buffer;
- (Byte *)createFileMD5:(NSData *)filedata;
@end
