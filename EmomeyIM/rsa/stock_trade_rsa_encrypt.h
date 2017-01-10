#ifndef _STOCK_TRADE_RSA_ENCRYPT_H
#define _STOCK_TRADE_RSA_ENCRYPT_H



//#ifdef __MAC_OS_X_VERSION
//#include <openssl/bn.h>
//#endif 
//#if __cplusplus

extern char * RSA_Encrypt(unsigned char *pc_data,int ilen,unsigned char *pc_keyN,int ikNlen,unsigned char *pc_keyE,int ikElen);
extern void ymObj_PrintChar(unsigned char* charBuf, int charLen);
extern unsigned char *preCode(unsigned char *byData,int nLen);

//extern void ymObj_PrintConent(ymObj_StringObj* pString);

//#endif

#endif
