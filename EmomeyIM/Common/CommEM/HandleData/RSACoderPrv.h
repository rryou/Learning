#pragma once

#include "rsa.h"
#import <UIKit/UIKit.h>

const uint32_t KEY_BIT_SIZE1024 = 1024;
const uint32_t EXPONENT100001 = 0x10001;

const uint32_t  KEYSTATE_NOKEY = 0;
const uint32_t  KEYSTATE_PUBLICKEY = 1;
const uint32_t  KEYSTATE_PRIVATEKEY = 2;

const int ERR_RSA_NOKEY = -1;

class CRSACoderPrv
{
public:
	CRSACoderPrv();
	virtual ~CRSACoderPrv();

	int SetKeySize(uint32_t dwBits);
	int ImportKeyItem(int nItemIndex, char* pcSrc, int nBytes);
	int CheckKey(Byte cKeyState);

	int ImportPrivateKey(uint32_t dwBits, Byte *pcN, Byte *pcE, Byte *pcD, Byte *pcP, Byte *pcQ,
				Byte *pcDP, Byte *pcDQ, Byte *pcQP);

	int EncryptPrivate(Byte *pcInput, uint32_t dwInLen, Byte *pcOutput, uint32_t dwOutLen);
	int DecryptPrivate(Byte *pcInput, uint32_t dwInLen, Byte *pcOutput, uint32_t& dwOutLen);

private:
	Byte			m_cKeyState;
	rsa_context		m_rsaContext;
};
