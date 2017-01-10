// BitStream.cpp: implementation of the CBitStream class.
//
//////////////////////////////////////////////////////////////////////

#include "BitStream.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBitStream::CBitStream()
{
	m_cBufType = 2;

	m_pcBuf = NULL;
	m_nBitLen = 0;

	m_pBuffer = NULL;
	m_uStartPos = 0;

	m_nCurPos = 0;
}

CBitStream::CBitStream(CBuffer* pBuffer, BOOL bRead)
{
	ASSERT(pBuffer && (bRead==FALSE || pBuffer->m_bSingleRead==true));

	m_pcBuf = NULL;
	m_nBitLen = 0;

	m_pBuffer = pBuffer;
	if (m_pBuffer)
	{
		if (bRead)
			m_uStartPos = m_pBuffer->m_nReadPos;
		else
			m_uStartPos = m_pBuffer->GetBufferLen();
	}

	m_nCurPos = 0;
	m_cBufType = 0;
}

CBitStream::CBitStream(PBYTE pcBuf, int nBufLen)
{
	SetBuffer(pcBuf, nBufLen);
}

CBitStream::CBitStream(int nBufLen)
{
	if (nBufLen > 0)
	{
		m_pcBuf = new BYTE[nBufLen];
		m_nBitLen = nBufLen * 8;
	}
	else
	{
		m_pcBuf = NULL;
		m_nBitLen = 0;
	}

	m_pBuffer = NULL;
	m_uStartPos = 0;

	m_nCurPos = 0;
	m_cBufType = 2;
}

CBitStream::~CBitStream()
{
	if (m_cBufType==2 && m_pcBuf)
		delete[] m_pcBuf;
}

void CBitStream::SetBuffer(PBYTE pcBuf, int nBufLen)
{
	ASSERT(pcBuf != NULL && nBufLen > 0);

	if (m_cBufType==2 && m_pcBuf)
		delete[] m_pcBuf;

	m_pcBuf = pcBuf;
	m_nBitLen = nBufLen*8;

	m_pBuffer = NULL;
	m_uStartPos = 0;

	m_nCurPos = 0;
	m_cBufType = 1;
}

int CBitStream::ReallocBuf(int nBits)
{
	ASSERT(m_cBufType==2);
	if(m_cBufType!=2)
		return 0;

	int nBufBytes = m_nBitLen/8;
	int nDataBytes = (nBits+7)/8;

	if(nBufBytes >= nDataBytes)
		return 0;

	const int nAddBytes = 4096;

	while(nBufBytes < nDataBytes)
		nBufBytes += nAddBytes;

	PBYTE pcNewBuf = new BYTE[nBufBytes];

	if(m_pcBuf)
	{
		if(m_nCurPos > 0)
			CopyMemory(pcNewBuf, m_pcBuf, (m_nCurPos+7)/8);

		delete[] m_pcBuf;
	}

	m_pcBuf = pcNewBuf;
	m_nBitLen = nBufBytes * 8;

	return nBufBytes;
}

BYTE CBitStream::WriteDWORD(DWORD dw, int nBits)
{
	ASSERT(nBits>0 && nBits<=32);

	if (nBits<=0 || nBits>32)
		return 0;

	BYTE* pcBufBase = NULL;

	if (m_cBufType==0)
	{
		if (m_pBuffer==NULL)
		{
			throw ERROR_BITSTREAM_NOBUFFER;
			return 0;
		}

		if (nBits>m_nBitLen)
		{
			DWORD dw = 0;
			m_pBuffer->Write(&dw, 4);
			m_nBitLen += 32;
		}

		pcBufBase = m_pBuffer->GetBuffer(m_uStartPos);
	}
	else
	{
		if (m_cBufType==2)
		{
			if (m_pcBuf==NULL || m_nCurPos+nBits>m_nBitLen)
				ReallocBuf(m_nCurPos+nBits);
		}
		if (m_pcBuf==NULL || m_nCurPos+nBits>m_nBitLen)
		{
			throw ERROR_BITSTREAM_NOMEM;
			return 0;
		}
		else
			pcBufBase = m_pcBuf;
	}

	int nRet = nBits;

	dw <<= (32 - nBits);
	PBYTE pcHigh = ((PBYTE)&dw) + 3;

	PBYTE pcBuf = pcBufBase + m_nCurPos/8;
	int nLastBits = m_nCurPos%8;

	if(nLastBits != 0)			// fill in the last byte
	{
		int nFillBits = 8 - nLastBits;
		*pcBuf &= (0xFF << nFillBits);

		*pcBuf += (BYTE)((*pcHigh) >> nLastBits);
		pcBuf++;

		if(nFillBits < nBits)
			dw <<= nFillBits;	// else, finish

		nBits -= nFillBits;
	}

	while(nBits > 0)
	{
		*pcBuf++ = *pcHigh--;
		nBits -= 8;
	}

	m_nCurPos += nRet;
	if (m_cBufType==0)
		m_nBitLen -= nRet;

	return nRet;
}


DWORD CBitStream::ReadDWORD(int nBits, BOOL bMovePos)
{
	ASSERT(nBits>0 && nBits<=32);

	if (nBits<=0 || nBits>32)
		return 0;

	BYTE* pcBufBase = NULL;

	if (m_cBufType==0)
	{
		if (m_pBuffer==NULL)
		{
			throw ERROR_BITSTREAM_NOBUFFER;
			return 0;
		}

		if (nBits>m_nBitLen)
		{
			try
			{
				if (bMovePos)
				{	
					m_pBuffer->SkipData(4);
					
					m_nBitLen += 32;
				}
				else
				{
					if (m_pBuffer->GetBufferLen()>0)
						m_nBitLen += 32;
					else
					{
						throw ERROR_BITSTREAM_NODATA;
						return 0;
					}
				}
			}
			catch(int n)
			{
				if (n==DATA_LACK)
				{
					throw ERROR_BITSTREAM_NODATA;
					return 0;
				}
				else
					throw;
			}
		}

		pcBufBase = m_pBuffer->GetBuffer(m_uStartPos);
	}
	else
	{
		if (m_pcBuf==NULL || m_nCurPos+nBits>m_nBitLen)
		{
			throw ERROR_BITSTREAM_NODATA;
			return 0;
		}

		pcBufBase = m_pcBuf;
	}


	PBYTE pcBuf = pcBufBase + m_nCurPos/8;
	int nLastBits = m_nCurPos%8;

	if (bMovePos)
	{
		m_nCurPos += nBits;
		if (m_cBufType==0)
			m_nBitLen -= nBits;
	}

	DWORD dw = 0;

	if(nLastBits != 0)
	{
		dw = (*pcBuf) & (0xFF >> nLastBits);
		pcBuf++;

		int nReadBits = 8 - nLastBits;
		if(nReadBits  > nBits)
			dw >>= (nReadBits - nBits);

		nBits -= nReadBits;
	}

	while(nBits > 0)
	{
		if(nBits >= 8)
		{
			dw = (dw << 8) + *pcBuf++;
			nBits -= 8;
		}
		else
		{
			dw = (dw << nBits) + (*pcBuf >> (8-nBits));
			nBits = 0;
		}
	}

	return dw;
}

CBitCode* CBitStream::MatchCodeEncode(DWORD& dw, CBitCode* pBitCodes, int nNumOfCodes)
{
	if(pBitCodes == NULL || nNumOfCodes <= 0)
		return NULL;

	CBitCode* pCode = pBitCodes;
	DWORD dwSave = 0;

	for(int i = 0; i < nNumOfCodes; i++, pCode++)
	{
		if(pCode->m_cDataType == 'C')			// const
		{
			if(dw == pCode->m_dwDataBias)
				break;
		}
		else if(pCode->m_cDataType == 'D')		// DWORD
		{
			dwSave = dw - pCode->m_dwDataBias;
			if((dwSave >> pCode->m_cDataLen) == 0)
			{
				dw = dwSave;
				break;
			}
		}
		else if(pCode->m_cDataType == 'I')		// INT
		{
			if(dw & 0x80000000)
			{
				dwSave = dw + pCode->m_dwDataBias;
				if((dwSave >> (pCode->m_cDataLen-1)) == (0xFFFFFFFF >> (pCode->m_cDataLen-1)))
				{
					dw = dwSave;
					break;
				}
			}
			else
			{
				dwSave = dw - pCode->m_dwDataBias;
				if((dwSave >> (pCode->m_cDataLen-1)) == 0)
				{
					dw = dwSave;
					break;
				}
			}
		}
		else if(pCode->m_cDataType == 'H')		// HUNDRED DWORD
		{
			if(dw % 100 == 0)
			{
				dwSave = dw/100 - pCode->m_dwDataBias;
				if((dwSave >> pCode->m_cDataLen) == 0)
				{
					dw = dwSave;
					break;
				}
			}
		}
		else if(pCode->m_cDataType == 'h')		// HUNDRED INT
		{
			INT32 iValue = dw;
			if(iValue % 100 == 0)
			{
				if(iValue < 0)
				{
					dwSave = iValue/100 + pCode->m_dwDataBias;
					if((dwSave >> (pCode->m_cDataLen-1)) == (0xFFFFFFFF >> (pCode->m_cDataLen-1)))
					{
						dw = dwSave;
						break;
					}
				}
				else
				{
					dwSave = iValue/100 - pCode->m_dwDataBias;
					if((dwSave >> (pCode->m_cDataLen-1)) == 0)
					{
						dw = dwSave;
						break;
					}
				}
			}
		}
		else if(pCode->m_cDataType == 'O')		// ORIGINAL
			break;
	}

	if(i == nNumOfCodes)
		return NULL;

	return pCode;
}

BYTE CBitStream::EncodeData(DWORD dwData, CBitCode* pBitCodes, int nNumOfCodes, PDWORD pdwBase, BOOL bReverse)
{
	DWORD dw = dwData;
	if(pdwBase != NULL)
	{
		if(bReverse)
			dw = *pdwBase - dwData;
		else
			dw = dwData - *pdwBase;
	}

	CBitCode* pCode = MatchCodeEncode(dw, pBitCodes, nNumOfCodes);
	if(pCode == NULL)
	{
		throw ERROR_BITSTREAM_NOCODE;
		return 0;
	}

#ifdef _DEBUG
	pCode->m_dwCodeCount++;
#endif

	if(pCode->m_cDataType == 'O')
	{
		if(pCode->m_cDataLen == 0
				|| pCode->m_cDataLen != 32 && (dwData >> pCode->m_cDataLen) != 0)
		{
			throw ERROR_BITSTREAM_NOCODE;
			return 0;
		}

		WriteDWORD(pCode->m_wCodeBits, pCode->m_cCodeLen);
		WriteDWORD(dwData, pCode->m_cDataLen);
	}
	else
	{
		WriteDWORD(pCode->m_wCodeBits, pCode->m_cCodeLen);
		if(pCode->m_cDataLen > 0)
			WriteDWORD(dw, pCode->m_cDataLen);
	}

	return (pCode->m_cCodeLen + pCode->m_cDataLen);
}

BYTE CBitStream::EncodeXInt32(XInt32 xData, CBitCode* pBitCodes, int nNumOfCodes, PXInt32 pxBase, BOOL bReverse)
{
	INT64 ll = 0;
	DWORD dw = 0;
	if(pxBase != NULL)
	{
		if(bReverse)
			ll = (INT64)(*pxBase) - (INT64)xData;
		else
			ll = (INT64)xData - (INT64)(*pxBase);
	}
	else
		ll = (INT64)xData;

	CBitCode* pCode = NULL;

	if(ll >= XInt32::m_nMinBase && ll <= XInt32::m_nMaxBase)
	{
		dw = (DWORD)ll;
		pCode = MatchCodeEncode(dw, pBitCodes, nNumOfCodes);
	}
	else
	{
		CBitCode* pC = pBitCodes;
		for(int i = 0; i < nNumOfCodes; i++, pC++)
		{
			if(pC->m_cDataType == 'O')
			{
				pCode = pC;
				break;
			}
		}
	}

	if(pCode == NULL)
	{
		throw ERROR_BITSTREAM_NOCODE;
		return 0;
	}

#ifdef _DEBUG
	pCode->m_dwCodeCount++;
#endif

	if(pCode->m_cDataType == 'O')
	{
		if(pCode->m_cDataLen != 32)
		{
			throw ERROR_BITSTREAM_NOCODE;
			return 0;
		}

		WriteDWORD(pCode->m_wCodeBits, pCode->m_cCodeLen);
		WriteDWORD(xData.GetRawData(), pCode->m_cDataLen);
	}
	else
	{
		WriteDWORD(pCode->m_wCodeBits, pCode->m_cCodeLen);
		if(pCode->m_cDataLen > 0)
			WriteDWORD(dw, pCode->m_cDataLen);
	}

	return (pCode->m_cCodeLen + pCode->m_cDataLen);
}

CBitCode* CBitStream::MatchCodeDecode(DWORD& dw, BYTE& cBytes, CBitCode* pBitCodes, int nNumOfCodes)
{
	dw = 0;
	cBytes = 0;

	if(pBitCodes == NULL || nNumOfCodes <= 0)
	{
		throw ERROR_BITSTREAM_NOCODE;
		return NULL;
	}

	int nReadBits;
	if (m_cBufType==0)
	{
		if (m_pBuffer)
		{
			nReadBits = m_nBitLen;
			if (nReadBits<16)
				nReadBits += m_pBuffer->GetBufferLen()*8;
		}
		else
			nReadBits = 0;
	}
	else
		nReadBits = m_nBitLen - m_nCurPos;
	if(nReadBits <= 0)
	{
		throw ERROR_BITSTREAM_NODATA;
		return NULL;
	}
	if (nReadBits>16)
		nReadBits = 16;

	WORD wCode = (WORD)ReadDWORD(nReadBits, FALSE);

	CBitCode* pCode = pBitCodes;
	for(int i = 0; i < nNumOfCodes; i++, pCode++)
	{
		if(pCode->m_wCodeBits == (wCode >> (nReadBits-pCode->m_cCodeLen)))
			break;
	}

	if(i == nNumOfCodes)
	{
		throw ERROR_BITSTREAM_NOCODE;
		return NULL;
	}

	m_nCurPos += pCode->m_cCodeLen;
	if (m_cBufType==0)
	{
		if (m_nBitLen>=32)
		{
			m_nBitLen -= pCode->m_cCodeLen;
			if (m_nBitLen>=32)
				m_nBitLen -= 32;
			else
				m_pBuffer->SkipData(4);
		}
		else
			m_nBitLen -= pCode->m_cCodeLen;
	}

	DWORD dwData = 0;
	if(pCode->m_cDataLen > 0)
		dwData = ReadDWORD(pCode->m_cDataLen);

	if(pCode->m_cDataType == 'C')			// const
		dw = pCode->m_dwDataBias;
	else if(pCode->m_cDataType == 'D')		// DWORD
		dw = dwData + pCode->m_dwDataBias;
	else if(pCode->m_cDataType == 'I')		// INT
	{
		if(dwData >> (pCode->m_cDataLen-1))
		{
			dwData |= (0xFFFFFFFF << pCode->m_cDataLen);
			dw = dwData - pCode->m_dwDataBias;
		}
		else
			dw = dwData + pCode->m_dwDataBias;
	}
	else if(pCode->m_cDataType == 'H')		// HUNDRED
		dw = (dwData + pCode->m_dwDataBias)*100;
	else if(pCode->m_cDataType == 'h')		// HUNDRED INT
	{
		if(dwData >> (pCode->m_cDataLen-1))
		{
			dwData |= (0xFFFFFFFF << pCode->m_cDataLen);
			INT32 iValue = dwData;
			iValue -= pCode->m_dwDataBias;

			dw = iValue * 100;
		}
		else
		{
			dw = (dwData + pCode->m_dwDataBias) * 100;
		}
	}
	else if(pCode->m_cDataType == 'O')		// ORIGINAL
		dw = dwData;

	cBytes = pCode->m_cCodeLen + pCode->m_cDataLen;

	return pCode;
}

BYTE CBitStream::DecodeData(DWORD& dwData, CBitCode* pBitCodes, int nNumOfCodes, PDWORD pdwBase, BOOL bReverse)
{
	dwData = 0;
	BYTE cBytes = 0;

	CBitCode* pCode = MatchCodeDecode(dwData, cBytes, pBitCodes, nNumOfCodes);
	if(pCode != NULL)
	{
		if(pCode->m_cDataType != 'O' && pdwBase != NULL)
		{
			if(bReverse)
				dwData = *pdwBase - dwData;
			else
				dwData = *pdwBase + dwData;
		}

	#ifdef _DEBUG
		pCode->m_dwCodeCount++;
	#endif
	}

	return cBytes;
}

BYTE CBitStream::DecodeXInt32(XInt32& xData, CBitCode* pBitCodes, int nNumOfCodes, PXInt32 pxBase, BOOL bReverse)
{
	xData = 0;
	BYTE cBytes = 0;

	DWORD dwData = 0;
	CBitCode* pCode = MatchCodeDecode(dwData, cBytes, pBitCodes, nNumOfCodes);
	if(pCode != NULL)
	{
		if(pCode->m_cDataType == 'O')
			xData.SetRawData(dwData);
		else
		{
			if(pxBase != NULL)
			{
				if(bReverse)
					xData = (INT64)(*pxBase) - (INT32)dwData;
				else
					xData = (INT64)(*pxBase) + (INT32)dwData;
			}
			else
				xData = (INT32)dwData;
		}

	#ifdef _DEBUG
		pCode->m_dwCodeCount++;
	#endif
	}

	return cBytes;
}

BYTE  CBitStream::WriteBOOL(BOOL bValue)
{
	if(bValue)
		return WriteDWORD(1, 1);
	else
		return WriteDWORD(0, 1);
}