#pragma once

#include "XInt32.h"
#include <stdlib.h>
#include <stdio.h>
#import <UIKit/UIKit.h>
const int ERROR_BITSTREAM_NOMEM = -10001;
const int ERROR_BITSTREAM_NODATA = -10002;
const int ERROR_BITSTREAM_NOCODE = -10003;
const int ERROR_BITSTREAM_NOBUFFER = -10004;

struct  CBitCode
{
	ushort	m_wCodeBits;
	Byte	m_cCodeLen;
	char	m_cDataType;	// 'C'-const, 'D'-DWORD, 'I'-INT32, 'X'-XInt32, 'H'-hundred DWORD, 'h'-hundred INT
	Byte	m_cDataLen;
	u_long	m_dwDataBias;
#ifdef _DEBUG
	DWORD	m_dwCodeCount;
#endif
};

class  CBitStream
{
public:
	CBitStream();
	CBitStream(CBuffer*, BOOL bRead);
	CBitStream(Byte *pcBuf, int nBufLen);
	CBitStream(int nBufLen);

	virtual ~CBitStream();

	void SetBuffer(Byte *pcBuf, int nBufLen);

	int  GetCurPos()	{ return m_nCurPos; }

	Byte  WriteDWORD(u_long dw, int nBit);
	u_long ReadDWORD(int nBit, BOOL bMovePos = TRUE);

	Byte EncodeData(u_long dwData, CBitCode* pBitCodes, int nNumOfCodes, u_long *pdwBase=NULL, BOOL bReverse=FALSE);
	Byte DecodeData(u_long& dwData, CBitCode* pBitCodes, int nNumOfCodes, u_long *pdwBase=NULL, BOOL bReverse=FALSE);

	Byte EncodeXInt32(XInt32 xData, CBitCode* pBitCodes, int nNumOfCodes, PXInt32 pxBase=NULL, BOOL bReverse=FALSE);
	Byte DecodeXInt32(XInt32& xData, CBitCode* pBitCodes, int nNumOfCodes, PXInt32 pxBase=NULL, BOOL bReverse=FALSE);

	Byte  WriteBOOL(BOOL bValue);
private:
	int ReallocBuf(int nBits);
	CBitCode* MatchCodeEncode(u_long& dw, CBitCode* pBitCodes, int nNumOfCodes);
	CBitCode* MatchCodeDecode(u_long& dw, Byte& cBytes, CBitCode* pBitCodes, int nNumOfCodes);

private:
	char		m_cBufType;		// 0: CBitStream(CBuffer*)
								// 1: CBitStream(PBYTE pcBuf, int nBufLen) or SetBuffer(PBYTE pcBuf, int nBufLen)
								// 2: CBitStream(int nBufLen) 内存自己管
	Byte		*m_pcBuf;
	int			m_nBitLen;

	CBuffer*	m_pBuffer;
	uint		m_uStartPos;

	int			m_nCurPos;
};
