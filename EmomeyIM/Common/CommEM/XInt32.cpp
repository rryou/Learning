// XInt32.cpp: implementation of the XInt32 class.
//
//////////////////////////////////////////////////////////////////////

#include "XInt32.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

int32_t XInt32::m_nMaxBase = 0x0FFFFFFF;	// 28bit
int32_t XInt32::m_nMinBase = 0xF0000000;
Byte  XInt32::m_cMaxMul = 7;

XInt32::XInt32()
{
	m_nBase = 0;
	m_cMul = 0;
}

XInt32::XInt32(const int64_t n)
{
	*this = n;
}

int64_t XInt32::GetValue()
{
	int64_t n = m_nBase;

	for(Byte c = 0; c < m_cMul; c++)
		n *= 16;

	return n;
}


XInt32 XInt32::operator=(const int64_t n)
{
	int64_t nBase = n;
	m_cMul = 0;

	int32_t nMod = 0;

	while(nBase > m_nMaxBase || nBase < m_nMinBase)
	{
		nMod = (int32_t)(nBase % 16);
		nBase /= 16;

		if(nMod >= 8)
			nBase++;
		else if(nMod <= -8)
			nBase--;

		m_cMul++;
		if(m_cMul >= m_cMaxMul)
			break;
	}

	m_nBase = (int32_t)nBase;

	return *this;
}

XInt32 XInt32::operator+=(const int64_t n)
{
//	*this = *this+n;
	*this = GetValue() + n;
	return *this;
}

int32_t XInt32::GetRawData()
{
	return *(int32_t*)this;
}

void XInt32::SetRawData(int32_t n)
{
	*(int32_t*)this = n;
}

BOOL XInt32::operator==(XInt32 x)
{
	int64_t n64 = *this;
	int64_t nX = x;

	return (n64 == nX);
}