// RSACoderPub.h: interface for the CRSACoderPub class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_RSACODERPUB_H__95C26BF4_BA01_4FC8_BF95_096ED9507808__INCLUDED_)
#define AFX_RSACODERPUB_H__95C26BF4_BA01_4FC8_BF95_096ED9507808__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "rsa.h"
#include "RSACoderPrv.h"

class CRSACoderPub  
{
public:
	CRSACoderPub();
	virtual ~CRSACoderPub();

	int SetKeySize(uint32_t dwBits);
	int ImportKeyItem(int nItemIndex, char* pcSrc, int nBytes);
	int CheckKey(Byte cKeyState);

	int ImportPublicKey(uint32_t dwBits, BytePtr pcN, BytePtr pcE);

	int EncryptPublic(BytePtr pcInput, uint32_t dwInLen, BytePtr pcOutput, uint32_t dwOutLen);
	int DecryptPublic(BytePtr pcInput, uint32_t dwInLen, BytePtr pcOutput, uint32_t& dwOutLen);

private:
	Byte			m_cKeyState;
	rsa_context		m_rsaContext;
};

#endif // !defined(AFX_RSACODERPUB_H__95C26BF4_BA01_4FC8_BF95_096ED9507808__INCLUDED_)
