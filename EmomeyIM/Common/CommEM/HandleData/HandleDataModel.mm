//
//  HandleDataModel.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "HandleDataModel.h"
#import <CommonCrypto/CommonDigest.h>
#import "EMLocalSocketManaget.h"
@interface HandleDataModel (){
}
@end;

@implementation HandleDataModel

- (id) init{
    self = [super init];
    if (self) {
        self.m_cCodeAlgorithm = 0;
        m_head = new CDataHead;
        self.m_wStatus = 0;
        self.m_wVersion = 0;
        self.m_wPriority = 0;
        self.m_cCodeAlgorithm = 0;
        self.m_dwSendBytes = 0;
        self.m_dwSendBytesLast = 0;
        self.m_dwSendBytesStat = 0;
        compress = new CCompress;
        compressbuffer = new CBuffer;
        compressbuffer->Initialize(40950,true);
        m_head->m_dwDataID = (int32_t)[[EMLocalSocketManaget sharedSocketManaget] getNewIndex];

    }
    return self;
}

- (void) sendSockData:(CBuffer &)buffer{

}

- (void) recvSockData:(CDataHead &) head sendbuffer:(CBuffer &)buffer{
    self->m_head = &head;
}

- (void)sendHead:(CBuffer &)buffer dataType:(short) wDataType{
   	m_head->m_wDataType = wDataType;
    m_head->m_dwDataLength = buffer.GetBufferLen()-_DataHeadLength_;
    m_head->Send((char*)buffer.GetBuffer());
}

#pragma SockManagetDelegate

- (void)receviedSocket:(EMSocketextend *)socket receivedata:(NSData *)sockData{
    if (sockData) {
        NSInteger templegth = [sockData length];
        Byte *answerbyte = (Byte *)[sockData bytes];
        CDataHead *tempHead = new CDataHead;
        tempHead->Recv((char *)answerbyte);
        CBuffer *temBuffer = new CBuffer;
        temBuffer->Initialize(40950,true);
        temBuffer->Write(answerbyte+16, (uint)(templegth - 16));
        [[EMDataPackCoder sharedEMDataPackcoder] decodeDataPackPub:*tempHead bufPack:*temBuffer];
        [self recvSockData:*tempHead sendbuffer:*temBuffer];
    }
}

- (void)sendSockPost{
    CBuffer *postBuffer = new CBuffer;
    postBuffer->Initialize(40950,true);
    [self sendSockData:*postBuffer];
    [[EMDataPackCoder sharedEMDataPackcoder] encodeDataPackPub:self.m_cCodeAlgorithm bufPack:*postBuffer];
    Byte *Bytesanswer = postBuffer->GetBuffer();
    NSInteger Byteslength= postBuffer->GetBufferLen();
    NSData *tempdata=  [[NSData alloc] initWithBytes:Bytesanswer length:Byteslength];
    [[EMLocalSocketManaget sharedSocketManaget] socketPostMessage:tempdata sendobject:self];
}
@end

@implementation CCompressSockData
- (bool)recvCompressData:(CBuffer &)buffer{
    if (!compressbuffer) {
        compressbuffer = new CBuffer;
    }
    compressbuffer->ClearBuffer();
    CCompress& compRecv = *compress;
    CBuffer& bufComp = *compressbuffer;
    try
    {
        bufComp.ClearBuffer();
    
        compRecv.m_lIn = buffer.ReadInt();
        if (compRecv.m_lIn==0)
            return TRUE;
        compRecv.m_pcIn = (char*)buffer.GetBuffer(buffer.m_nReadPos);
        buffer.SkipData(compRecv.m_lIn);
        if (compRecv.Decode())
        {
            bufComp.Write(compRecv.m_pcOut, compRecv.m_lOut);
            
            _s_n64CompIn += compRecv.m_lIn;
            _s_n64CompOut += compRecv.m_lOut;
            
            return TRUE;
        }
    }
    catch(...)
    {
    }
    
    return FALSE;
}

- (bool)recvCompressData2:(CBuffer &)buffer{
    if (!compressbuffer) {
        compressbuffer = new CBuffer;
        compressbuffer->Initialize(40950,true);

    }
    if (!compress) {
        compress = new CCompress;
    }
    
    CCompress& compRecv = *compress;
    CBuffer& bufComp = *compressbuffer;
    try
    {
        char cCompress = buffer.ReadChar();
        if (cCompress){
            return  [self recvCompressData:buffer] ;
        }
        else{
            bufComp.ClearBuffer();
            bufComp.Write(buffer.GetBuffer(buffer.m_nReadPos), compRecv.m_lIn);
            buffer.SkipData(compRecv.m_lIn);
            return TRUE;
        }
    }
    catch(...)
    {
    }
    
    return FALSE;
    
}

- (bool)sendCompressData:(CBuffer &)buffer{
    if (!compressbuffer ||!compress)
        return FALSE;
    
    CCompress& compSend = *compress;
    CBuffer& bufComp = *compressbuffer;
    
    BOOL bRet = FALSE;
    
    uint nLen = bufComp.GetBufferLen();
    if (nLen > 0){
        try{
            compSend.m_pcIn = (char*)bufComp.GetBuffer();
            compSend.m_lIn = (long)nLen;
            
            if (compSend.Encode() && compSend.m_lOut>0 && compSend.m_pcOut){
                buffer.WriteInt(compSend.m_lOut);
                buffer.Write(compSend.m_pcOut, compSend.m_lOut);
                bRet = TRUE;
            }
        }
        catch(...){
            bRet = FALSE;
            //OutputDebugString("SendCompressData Error");
        }
    }
    return bRet;
}

- (CBuffer *)getCompress{
    if (!self->compressbuffer) {
        self->compressbuffer = new CBuffer;
        self->compressbuffer->Initialize(40950,true);
    }
    return self->compressbuffer;
}

- (void)compress2Buf:(CBuffer &)buffer wDataType:(short)wDataType{
    buffer.Add(_DataHeadLength_);
    if ([self sendCompressData:buffer]) {
        [self sendHead:buffer dataType:wDataType];
        self.m_wStatus =  WantRecv;
    }else{
        buffer.ClearBuffer();
    }
}

- (void)compressACK2Buf:(CBuffer &)buffer{
    buffer.Write(m_head, _DataHeadLength_);
    if ([self sendCompressData:buffer]) {
        [self sendHead:buffer dataType:(m_head->m_wDataType +1)];
    }else{
        buffer.ClearBuffer();
    }
}


- (Byte *)createFileMD5:(NSData *)filedata{
    Byte *str = (Byte *)[filedata bytes];
    Byte r[16];
    CC_MD5(str, (int)filedata.length, r);
    return r;
}
@end
