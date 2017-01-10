//
//  EMDataPackCoder.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/7.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "EMDataPackCoder.h"
#import <iostream>
#import "stock_trade_rsa_encrypt.h"
#import "EMTypeConversion.h"
#import "EMCommData.h"
static EMDataPackCoder *shardEMdataPackCoder= nil;
@implementation EMDataPackCoder

+(EMDataPackCoder*) sharedEMDataPackcoder{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shardEMdataPackCoder  = [[self alloc] init];
    });
    return shardEMdataPackCoder;
}


- (id)init{
    self = [super init];
    if (self) {
        m_aesCoder = new CAESCoder;
        m_xorCoder = new CXorCoder;
        m_rsaCoderPub = new CRSACoderPub;
    }
    return self;
}

- (int)setAESEncodeContext:(u_char *)pUserKey nBits:(int)bits pcouter:(u_char [16])couter{
    return m_aesCoder->SetCTREncodeContext(pUserKey, bits, couter);
}

- (int)setXORCodeTable:(Byte *)pcCodeTable ntablesize:(int)nTableSize{
    return m_xorCoder->SetCodeTable(pcCodeTable, nTableSize);
}

- (ushort)generateCheckSum:(Byte *)pcData dataLen:(uint32_t)dwDataLen{
    uint32_t dwCheckSum = 0;
    for(uint32_t dw = 0; dw < dwDataLen; dw++){
        dwCheckSum += (uint32_t)pcData[dw];
    }
    return ushort(dwCheckSum & 0xFFFF);
}

- (int)encodeDataPackPub:(Byte)cAlgorithm bufPack:(CBuffer &)bufPack{
    int nPackLength = bufPack.GetBufferLen();
    if(nPackLength < _DataHeadLength_)
        return -1;
    CDataHead* pdateHead = (CDataHead *)bufPack.GetBuffer();
    
    Byte *pcContent = (Byte *)bufPack.GetBuffer() + _DataHeadLength_;
    uint32_t dwCntLength = nPackLength - _DataHeadLength_;
    
    // calc checksum
    ushort wCheckSum = [self generateCheckSum:pcContent dataLen:dwCntLength];
    Byte cPackCode = DATAENCODE_PLAIN;
    
    if(cAlgorithm == DATAENCODE_AES)
    {
        if(m_aesCoder->EncodeCTR(pcContent, dwCntLength) == dwCntLength)
            cPackCode = DATAENCODE_AES;
        else
            return -2;
    }else if(cAlgorithm == DATAENCODE_XOR){
        if(m_xorCoder->EncodeXOR(pcContent, dwCntLength) == dwCntLength)
            cPackCode = DATAENCODE_XOR;
        else
            return -2;
    }else if(cAlgorithm == DATAENCODE_RSA){
        uint32_t dwCipherLen = 128;
        Byte pcCipherData[128];
        if(m_rsaCoderPub->EncryptPublic(pcContent, dwCntLength, pcCipherData, dwCipherLen) == 0){
            cPackCode = DATAENCODE_RSA;
            pdateHead->m_dwDataLength = dwCipherLen;
            bufPack.DeleteEnd(dwCntLength);
            bufPack.Write(pcCipherData, dwCipherLen);
        }
    }
    pdateHead->m_wChecksum = (ushort)(((wCheckSum & 0x0FFF) << 4) | (cPackCode & 0x0F));
    return 0;
}

- (int)decodeDataPackPub:(CDataHead &)head bufPack:(CBuffer &)bufPack{
    uint32_t dwCntLength = bufPack.GetBufferLen();
    if(head.m_dwDataLength != dwCntLength)
        return -1;
    
    Byte *pcContent = bufPack.GetBuffer();
    // get checksum and algorithm
    ushort wCheckSum = (ushort)(head.m_wChecksum >> 4);
    Byte cAlgorithm = (Byte)(head.m_wChecksum & 0x0F);
    
    if(cAlgorithm == DATAENCODE_PLAIN)
    {
        ushort wDecodeCheckSum = (ushort)([self generateCheckSum:pcContent dataLen:dwCntLength] & 0x0FFF);
        if(wDecodeCheckSum == wCheckSum)
            return 0;
    }
    else if(cAlgorithm == DATAENCODE_AES)
    {
        if(m_aesCoder->EncodeCTR(pcContent, dwCntLength) == dwCntLength)
        {
            ushort wDecodeCheckSum = (ushort)([self generateCheckSum:pcContent dataLen:dwCntLength] & 0x0FFF);
            if(wDecodeCheckSum == wCheckSum)
                return 0;
        }
    }
    else if(cAlgorithm == DATAENCODE_XOR)
    {
        if(m_xorCoder->EncodeXOR(pcContent, dwCntLength) == dwCntLength)
        {
            ushort wDecodeCheckSum = (ushort)([self generateCheckSum:pcContent dataLen:dwCntLength] & 0x0FFF);
            if(wDecodeCheckSum == wCheckSum)
                return 0;
        }
    }
    else if(cAlgorithm == DATAENCODE_RSA)
    {
        uint32_t dwDecryptLen = 128;
        Byte  pcDecryptData[128];
        if(m_rsaCoderPub->DecryptPublic(pcContent, dwCntLength, pcDecryptData, dwDecryptLen) == 0)
        {
            ushort wDecodeCheckSum = (ushort)([self generateCheckSum:pcDecryptData dataLen:dwDecryptLen]&0x0FFF);
            if(wDecodeCheckSum == wCheckSum)
            {
                head.m_dwDataLength = dwDecryptLen;
                
                bufPack.DeleteEnd(dwCntLength);
                bufPack.Write(pcDecryptData, dwDecryptLen);
                
                return 0;
            }
        }
    }
    else if(cAlgorithm >= DATAENCODE_RSA_PLAIN)
    {
        if(dwCntLength == 0)
            return -2;
        // 1 byte RSA length, RSA data, PLAIN/AES/XOR data
        uint32_t dwLenRSA = *pcContent;
        if(dwCntLength < 1 + dwLenRSA)
            return -3;
        
        Byte *pcRSA = pcContent + 1;
        Byte *pcSymmetric = pcRSA + dwLenRSA;
        uint32_t dwLenSymmetric = dwCntLength - 1 - dwLenRSA;
        
        uint32_t dwDecryptLen = 128;
        Byte  pcDecryptData[128];
        
        if(m_rsaCoderPub->DecryptPublic(pcRSA, dwLenRSA, pcDecryptData, dwDecryptLen) == 0)
        {
            // 2 bytes nBits, nBits/8 bytes key, 16 bytes counter
            // 1 byte table size, 64 bytes XOR table
            if(dwDecryptLen < 19)
                return -4;
            Byte *pc = pcDecryptData;
            int nBits = *(ushort *)pc;
            pc += 2;
            
            int nKeyBytes = nBits/8;
            if (nBits % 8 != 0 || (int)dwDecryptLen <= 19 + nKeyBytes)
                return -4;
            
            Byte *pUserKey = pc;
            pc += nKeyBytes;
            
            Byte pcCounter[16];
            memcpy(pcCounter, pc, 16);
            pc += 16;
            
            int nXORTableSize = *pc;
            pc++;
            
            if(dwDecryptLen != 19 + nKeyBytes + nXORTableSize)
                return -4;
            Byte *pcXORTable = pc;
            if(m_aesCoder->SetCTREncodeContext(pUserKey, nBits, pcCounter) != 0)
                return -5;
//            [[EMCommData sharedEMCommData] setAesCode:pUserKey nBitsValue:nBits counter:pcCounter];
            
            if(m_xorCoder->SetCodeTable(pcXORTable, nXORTableSize) != 0)
                return -5;
//            [[EMCommData sharedEMCommData] setXortable:pcXORTable tabledataSize:(int32_t)nXORTableSize];
            
            if(dwLenSymmetric > 0)
            {
                Byte cAlgo = cAlgorithm - DATAENCODE_RSA_PLAIN;
                if(cAlgo == DATAENCODE_AES)
                {
                    if(m_aesCoder->EncodeCTR(pcSymmetric, dwLenSymmetric) != dwLenSymmetric)
                        return -6;
                }
                else if(cAlgo == DATAENCODE_XOR)
                {
                    if(m_xorCoder->EncodeXOR(pcSymmetric, dwLenSymmetric) != dwLenSymmetric)
                        return -6;
                }
                else if(cAlgo != DATAENCODE_PLAIN)
                    return -6;
                
                ushort wDecodeCheckSum = (ushort) ([self generateCheckSum:pcSymmetric  dataLen:dwLenSymmetric]&0x0FFF);
                if(wDecodeCheckSum != wCheckSum)
                    return -7;
                memmove(pcContent, pcSymmetric, dwLenSymmetric);
            }
            bufPack.DeleteEnd(1 + dwLenRSA);
            head.m_dwDataLength = dwLenSymmetric;
            return 0;
        }
    }
    return -10;
}


@end
