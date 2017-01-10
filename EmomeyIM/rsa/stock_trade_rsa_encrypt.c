//
//
//
#include <stdlib.h>

#ifdef WIN32
	#include "bn.h"
	#include "ossl_typ.h"
#endif

#include "stock_trade_rsa_encrypt.h"
#include "openssl/include/openssl/rsa.h"
#include <string.h>

unsigned char *preCode(unsigned char *byData,int nLen)
{
	unsigned char*  result = NULL;
	if(nLen % 2 == 0)
    {
		unsigned char tmp;
		int i = 0;
		result = (unsigned char *)malloc(nLen / 2);
//        memset(result, 0, nLen);
		//unsigned char code;
		for(;i<nLen; i++)
        {
			tmp=byData[i];
			if(tmp>='0'&&tmp<='9'){
				tmp-='0';
			}
			else if(tmp>='A'&&tmp<='F'){
				tmp=tmp-'A'+10;
			}else if(tmp>='a'&&tmp<='f'){
                tmp=tmp-'a'+10;
            }
			if(i%2==1){
				result[i/2]=(result[i/2]<<4)|tmp;
			}else {
				result[i/2]=tmp;
			}
		}
	}
	//OPENSSL_free(byData);
	return result;
}

char * RSA_Encrypt(unsigned char *pc_data,int ilen,unsigned char *pc_keyN,int ikNlen,unsigned char *pc_keyE,int ikElen)
//{
//	BIGNUM *publicKeyN = BN_new();
//	BIGNUM *publicKeyE = BN_new();
//	BIGNUM *plaintText = BN_new();
//	BIGNUM *cryptographText = BN_new();
//	BN_CTX *ctx = BN_CTX_new();
//	unsigned char *publicKeyNTmp = preCode(pc_keyN,ikNlen);
//	unsigned char *publicKeyETmp = preCode(pc_keyE,ikElen);
//	char *result = 0;
//    
//	BN_bin2bn(publicKeyNTmp,ikNlen,publicKeyN);
//	BN_bin2bn(publicKeyETmp,ikElen,publicKeyE);
//	BN_bin2bn(pc_data,ilen,plaintText);
//	BN_mod_exp(cryptographText,plaintText,publicKeyE,publicKeyN,ctx);
//	BN_CTX_free(ctx);
//    
//	result = (char*)preCode((unsigned char *)BN_bn2hex(cryptographText), 128);
//	BN_free(publicKeyN);
//	BN_free(publicKeyE);
//	BN_free(plaintText);
//	BN_free(cryptographText);
//	free(publicKeyETmp);
//	free(publicKeyNTmp);
//	return result;
//}
{
    BIGNUM *publicKeyN = BN_new();
    BIGNUM *publicKeyE = BN_new();
    BIGNUM *plaintText = BN_new();
    BIGNUM *cryptographText = BN_new();
    BN_CTX *ctx = BN_CTX_new();
    
    BN_bin2bn(pc_keyN,ikNlen,publicKeyN);
    BN_bin2bn(pc_keyE,ikElen,publicKeyE);
    BN_bin2bn(pc_data,ilen,plaintText);
    BN_mod_exp(cryptographText,plaintText,publicKeyE,publicKeyN,ctx);
    BN_CTX_free(ctx);
    
//    char *temp = BN_bn2hex(cryptographText);
//    char *result = preCode((unsigned char *)temp, ikNlen);
    char *result = BN_bn2hex(cryptographText);
    
    BN_free(publicKeyN);
    BN_free(publicKeyE);
    BN_free(plaintText);
    BN_free(cryptographText);
    return result;
}

void ymObj_PrintChar(unsigned char* charBuf, int charLen)
{
    printf("ymObj_PrintChar %d\n", charLen);

    printf("十六进制：（四个数据后添加一个空格）：");

    for (int i=0; i<charLen; i++)
    {
        if (0 == i%4) {
            printf(" ");
        }
        unsigned char *p = (unsigned char *)charBuf+i;
        printf("%02x", *p);

    }
    printf("\n");
    
    
    printf("十进制：（一个数据后添加一个空格）：");

    for (int j=0; j<charLen; j++) {
        
        unsigned char *p = (unsigned char *)charBuf+j;
        printf("%d ", *p);
    }
    printf("\n");

}

//void ymObj_PrintConent(ymObj_StringObj* pString)
//{
//    printf("ymObj_StringObj %d \n", pString->m_iLen);
//    for (int i=0; i<pString->m_iLen; i++) {
//        unsigned short*p = pString->m_pWSZText+i;
//        printf("%c", *p);
//        printf("%c%c", *p, *(p+1));
//    }
//}

//#endif
