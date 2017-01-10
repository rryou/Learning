// RSACoderPub.cpp: implementation of the CRSACoderPub class.
//
//////////////////////////////////////////////////////////////////////

#include "RSACoderPub.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
//using namespace std;
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CRSACoderPub::CRSACoderPub()
{
	m_cKeyState = KEYSTATE_NOKEY;
	rsa_init(&m_rsaContext);
}

CRSACoderPub::~CRSACoderPub()
{
	rsa_free(&m_rsaContext);
}

int CRSACoderPub::SetKeySize(uint32_t dwBits)
{
	rsa_init(&m_rsaContext);
	m_rsaContext.len = dwBits/8;

	return 0;
}

int CRSACoderPub::ImportKeyItem(int nItemIndex, char* pcSrc, int nBytes)
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

int CRSACoderPub::CheckKey(Byte cKeyState)
{
	if(cKeyState == KEYSTATE_PUBLICKEY)
	{
		if(m_rsaContext.N.n > 0 && m_rsaContext.E.n > 0)
		{
			if(rsa_check_pubkey(&m_rsaContext) == 0)
			{
				m_cKeyState = KEYSTATE_PUBLICKEY;
				return 0;
			}
		}
	}
	return -1;
}

int CRSACoderPub::ImportPublicKey(uint32_t dwBits, Byte *pcN, Byte *pcE)
{
	int nRet = rsa_import_key(&m_rsaContext, dwBits, pcN, pcE, NULL, NULL, NULL, NULL, NULL, NULL);
	if(nRet != 0)
		return nRet;

	nRet = rsa_check_pubkey(&m_rsaContext);

	if(nRet == 0)
		m_cKeyState = KEYSTATE_PUBLICKEY;

	return nRet;
}

int CRSACoderPub::EncryptPublic(BytePtr pcInput, uint32_t dwInLen, BytePtr pcOutput, uint32_t dwOutLen)
{
	return rsa_pkcs1_encrypt_public(&m_rsaContext, pcInput, dwInLen, pcOutput, dwOutLen);
}

int CRSACoderPub::DecryptPublic(Byte *pcInput, uint32_t dwInLen, Byte *pcOutput, uint32_t& dwOutLen)
{
	return rsa_pkcs1_decrypt_public(&m_rsaContext, pcInput, dwInLen, pcOutput, (uint *)&dwOutLen);
}
