#include <stdlib.h>
#include <stdio.h>
#include <UIKit/UIKit.h>


const int MAX_TABLE_SIZE = 0x10000;

class  CXorCoder
{
public:
	CXorCoder(void);
	~CXorCoder(void);

	int SetCodeTable(Byte *pcCodeTable, int nTableSize);
	uint32_t EncodeXOR(Byte *pcSrc, long dwLength);

	Byte	   *m_pcCodeTable;
	int			m_nTableize;
};
