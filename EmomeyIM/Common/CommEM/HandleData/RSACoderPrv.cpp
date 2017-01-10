// RSACoderPrv.cpp: implementation of the CRSACoderPrv class.
//
//////////////////////////////////////////////////////////////////////

#include "RSACoderPrv.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CRSACoderPrv::CRSACoderPrv()
{
	m_cKeyState = KEYSTATE_NOKEY;
	rsa_init(&m_rsaContext);
}

CRSACoderPrv::~CRSACoderPrv()
{
	rsa_free(&m_rsaContext);
}

int CRSACoderPrv::SetKeySize(uint32_t dwBits)
{
	rsa_init(&m_rsaContext);
	m_rsaContext.len = dwBits/8;

	return 0;
}

int CRSACoderPrv::ImportKeyItem(int nItemIndex, char* pcSrc, int nBytes)
{
	int nRet = -1;

	if(nItemIndex == 0)
		nRet = mpi_read_bytes(&m_rsaContext.N, pcSrc, nBytes);
	else if(nItemIndex == 1)
		nRet = mpi_read_bytes(&m_rsaContext.E, pcSrc, nBytes);
	else if(nItemIndex == 2)
		nRet = mpi_read_bytes(&m_rsaContext.D, pcSrc, nBytes);
	else if(nItemIndex == 3)
		nRet = mpi_read_bytes(&m_rsaContext.P, pcSrc, nBytes);
	else if(nItemIndex == 4)
		nRet = mpi_read_bytes(&m_rsaContext.Q, pcSrc, nBytes);
	else if(nItemIndex == 5)
		nRet = mpi_read_bytes(&m_rsaContext.DP, pcSrc, nBytes);
	else if(nItemIndex == 6)
		nRet = mpi_read_bytes(&m_rsaContext.DQ, pcSrc, nBytes);
	else if(nItemIndex == 7)
		nRet = mpi_read_bytes(&m_rsaContext.QP, pcSrc, nBytes);
	return nRet;
}

int CRSACoderPrv::CheckKey(Byte cKeyState)
{
	if(cKeyState == KEYSTATE_PRIVATEKEY)
	{
		if(m_rsaContext.N.n > 0 && m_rsaContext.E.n > 0
				&& m_rsaContext.D.n > 0 && m_rsaContext.P.n > 0
				&& m_rsaContext.Q.n > 0 && m_rsaContext.DP.n > 0
				&& m_rsaContext.DQ.n > 0 && m_rsaContext.QP.n > 0)
		{
			if(rsa_check_privkey(&m_rsaContext) == 0)
			{
				m_cKeyState = KEYSTATE_PRIVATEKEY;
				return 0;
			}
		}
	}
	return -1;
}

int CRSACoderPrv::ImportPrivateKey(uint32_t dwBits, Byte *pcN, Byte *pcE, Byte *pcD, Byte *pcP, Byte *pcQ,
				Byte *pcDP, Byte *pcDQ, Byte *pcQP)
{
	int nRet = rsa_import_key(&m_rsaContext, dwBits, pcN, pcE, pcD, pcP, pcQ, pcDP, pcDQ, pcQP);
	if(nRet != 0)
		return nRet;

	nRet = rsa_check_privkey(&m_rsaContext);

	if(nRet == 0)
		m_cKeyState = KEYSTATE_PRIVATEKEY;

	return nRet;
}

int CRSACoderPrv::EncryptPrivate(Byte *pcInput, uint32_t dwInLen, Byte *pcOutput, uint32_t dwOutLen)
{
	if(m_cKeyState < KEYSTATE_PRIVATEKEY)
		return ERR_RSA_NOKEY;

	return rsa_pkcs1_encrypt_private(&m_rsaContext, pcInput, dwInLen, pcOutput, dwOutLen);
}

int CRSACoderPrv::DecryptPrivate(Byte *pcInput, uint32_t dwInLen, Byte *pcOutput, uint32_t& dwOutLen)
{
	if(m_cKeyState < KEYSTATE_PRIVATEKEY)
		return ERR_RSA_NOKEY;

	return rsa_pkcs1_decrypt_private(&m_rsaContext, pcInput, dwInLen, pcOutput, (uint *)&dwOutLen);
}
