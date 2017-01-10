
#include "xorcoder.h"
#import "EMCommData.h"

CXorCoder::CXorCoder(void)
{
	m_pcCodeTable = NULL;
	m_nTableize = 0;
}

CXorCoder::~CXorCoder(void)
{
	if(m_pcCodeTable != NULL)
		delete[] m_pcCodeTable;
}

int CXorCoder::SetCodeTable(Byte *pcCodeTable, int nTableSize)
{
	if(pcCodeTable != NULL && nTableSize > 0 && nTableSize <= MAX_TABLE_SIZE)
	{
		if(m_pcCodeTable != NULL)
			delete[] m_pcCodeTable;

		m_pcCodeTable = new Byte[nTableSize];
		m_nTableize = nTableSize;
		memcpy(m_pcCodeTable, pcCodeTable, m_nTableize);

		return 0;
	}
	return -1;
}

uint32_t CXorCoder::EncodeXOR(Byte *pcSrc, long dwLength)
{
	if(m_pcCodeTable == NULL || m_nTableize <= 0)
		return 0;

	int nIndex = dwLength % m_nTableize;
	for(long dw = 0; dw < dwLength; dw++)
	{
		pcSrc[dw] ^= m_pcCodeTable[nIndex];
		nIndex = (nIndex+1) % m_nTableize;
	}
	return dwLength;
}
