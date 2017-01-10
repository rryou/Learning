//
//  EmXorCoder.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/18.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
const int MAX_TABLE_SIZE = 0x10000;
//class YM_DLLEXPORT CXorCoder
//{
//public:
//    CXorCoder(void);
//    ~CXorCoder(void);
//
//    int SetCodeTable(PBYTE pcCodeTable, int nTableSize);
//    DWORD EncodeXOR(PBYTE pcSrc, DWORD dwLength);
//
//    PBYTE		m_pcCodeTable;
//    int			m_nTableize;
//};


@interface EmXorCoder : NSObject
- (NSInteger )setCodeTable:(Byte *)pcCodeTable tableSize: (NSInteger )nTableSize;
- (long ) encodeXcode:(Byte *)pcSrc pclength: (long) dwlength;
@end