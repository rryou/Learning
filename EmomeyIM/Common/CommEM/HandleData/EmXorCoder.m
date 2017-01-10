//
//  EmXorCoder.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/18.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "EmXorCoder.h"
@interface EmXorCoder (){
}
@property (nonatomic, assign)  Byte *m_pcCodeTable;
@property (nonatomic, assign) NSInteger m_nTableize;
@end;


@implementation EmXorCoder

-(id)init{
    self = [super init];
    if (self) {
        _m_nTableize = 0;
        _m_pcCodeTable = nil;
    }
    
    return self;
}

//
//int CXorCoder::SetCodeTable(PBYTE pcCodeTable, int nTableSize)
//{
//    if(pcCodeTable != NULL && nTableSize > 0 && nTableSize <= MAX_TABLE_SIZE)
//    {
//        if(m_pcCodeTable != NULL)
//            delete[] m_pcCodeTable;
//        
//        m_pcCodeTable = new BYTE[nTableSize];
//        m_nTableize = nTableSize;
//        CopyMemory(m_pcCodeTable, pcCodeTable, m_nTableize);
//        
//        return 0;
//    }
//    
//    return -1;
//}

- (NSInteger) setCodeTable:(Byte *)pcCodeTable tableSize:(NSInteger)nTableSize{
    if(pcCodeTable&&nTableSize >0 &&nTableSize <MAX_TABLE_SIZE){
        if (self.m_pcCodeTable) {
            free(self.m_pcCodeTable);
        }
        self.m_pcCodeTable =(Byte *)malloc(nTableSize);
        memcpy(self.m_pcCodeTable, pcCodeTable, nTableSize);
        return 0;
    }
    return 1;
}


//DWORD CXorCoder::EncodeXOR(PBYTE pcSrc, DWORD dwLength)
//{
//    if(m_pcCodeTable == NULL || m_nTableize <= 0)
//        return 0;
//    
//    int nIndex = dwLength % m_nTableize;
//    for(DWORD dw = 0; dw < dwLength; dw++)
//    {
//        pcSrc[dw] ^= m_pcCodeTable[nIndex];
//        nIndex = (nIndex+1) % m_nTableize;
//    }
//    
//    return dwLength;
//}

- (long) encodeXcode:(Byte *)pcSrc pclength:(long)dwlength{
    if (self.m_pcCodeTable ==nil || self.m_pcCodeTable<=0) {
        return 0;
    }
    long nIndex = dwlength%self.m_nTableize;
    for ( long dw = 0 ; dw <dwlength  ; dw ++) {
        pcSrc[dw] ^=self.m_pcCodeTable[nIndex];
        nIndex = (nIndex +1)%_m_nTableize;
    }
    return dwlength;
}

//CXorCoder::CXorCoder(void)
//{
//    m_pcCodeTable = NULL;
//    m_nTableize = 0;
//}
//
//CXorCoder::~CXorCoder(void)
//{
//    if(m_pcCodeTable != NULL)
//        delete[] m_pcCodeTable;
//}


- (void)dealloc{
    free(self.m_pcCodeTable);
}

@end
