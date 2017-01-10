//
//  EMDataPackCoder.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/7.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHead.h"
#import "Buffer.h"
#import "AESCoder.h"
#import "xorcoder.h"
#import <UIKit/UIKit.h>
//#import "RSACoderPrv.h"
#import "RSACoderPub.h"

const Byte DATAENCODE_PLAIN = 0;
const Byte DATAENCODE_XOR = 1;
const Byte DATAENCODE_AES = 2;
const Byte DATAENCODE_RSA = 3;

const Byte DATAENCODE_RSA_PLAIN = 4;
const Byte DATAENCODE_RSA_XOR = 5;
const Byte DATAENCODE_RSA_AES = 6;


@interface EMDataPackCoder : NSObject{
    CAESCoder		*m_aesCoder;
    CXorCoder		*m_xorCoder;
    CRSACoderPub	*m_rsaCoderPub;
}
- (int)setAESEncodeContext:(u_char *)pUserKey nBits:(int) bits pcouter:(u_char [16])couter;
- (int)setXORCodeTable:(Byte *)pcCodeTable ntablesize:(int) nTableSize;

//- (Byte *)rsaEncode:(Byte *)pc_data datalength:(uint) length;

- (int) encodeDataPackPub:(Byte )cAlgorithm bufPack:(CBuffer& )bufPack;

- (int) decodeDataPackPub:(CDataHead &)head bufPack:(CBuffer& )bufPack;

//- (char *)createHeadData:(CDataHead *)hedad;

- (ushort)generateCheckSum:(Byte *)pcData  dataLen:(uint32_t )dwDataLen;
+(EMDataPackCoder*) sharedEMDataPackcoder;
@end
