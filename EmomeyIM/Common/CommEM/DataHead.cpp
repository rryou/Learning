

#include "DataHead.h"
#include <UIKit/UIKit.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif
//using namespace std;
long g_lStaticDataID = 1;

//////////////////////////////////////////////////////////////////////

CDataHead::CDataHead()
{
	m_wHeadID = 0x9988;
    m_wReserved = 0;
}

CDataHead::CDataHead(CDataHeadOld& src)
{
//	ZeroMemory(this, sizeof(CDataHead));
	
	m_wHeadID = src.m_wHeadID;
	m_dwDataID = src.m_dwDataID;
	m_wDataType = src.m_wDataType;
	m_dwDataLength = src.m_dwDataLength;
}

void CDataHead::Initial()
{
//	ZeroMemory(this, sizeof(CDataHead));

	m_wHeadID = 0x9988;
//	m_dwDataID = (DWORD)InterlockedIncrement(&g_lStaticDataID);
}

uint32_t CDataHead::Recv(char* pcData)
{
    memcpy(this, pcData, _DataHeadLength_);
//	CopyMemory(this, pcData, _DataHeadLength_);
	return _DataHeadLength_;
}

uint32_t CDataHead::Send(char* pcData)
{
	memcpy(pcData, this, _DataHeadLength_);
	return _DataHeadLength_;
}

//////////////////////////////////////////////////////////////////////

inline void g_Mem2Long(void* pValue, char* pcMem)
{
	*((long*)pValue) = htonl(*(long*)pcMem);
}

inline void g_Mem2Short(void* pValue, char* pcMem)
{
	*((short*)pValue) = htons(*(short*)pcMem);
}

inline void g_Long2Mem(char* pcMem, void* pValue)
{
	*(long*)pcMem = htonl(*(long*)pValue);
}

inline void g_Short2Mem(char* pcMem, void* pValue)
{
	*(short*)pcMem = htons(*(short*)pValue);
}

CDataHeadOld::CDataHeadOld()
{
//	ZeroMemory(this, sizeof(CDataHeadOld));
}

CDataHeadOld::CDataHeadOld(CDataHead& src)
{
   // ZeroMemory(this, sizeof(CDataHeadOld));
	
	m_wHeadID = src.m_wHeadID;
	m_dwDataID = src.m_dwDataID;
	m_wDataType = src.m_wDataType;
	m_dwDataLength = src.m_dwDataLength;
}

void CDataHeadOld::Initial()
{
//	ZeroMemory(this, sizeof(CDataHeadOld));

	m_wHeadID = 0x9988;
//	m_dwDataID = (DWORD)InterlockedIncrement(&g_lStaticDataID);
}

u_long CDataHeadOld::Recv(char* pcData)
{
	g_Mem2Short(&m_wHeadID, pcData);
	g_Mem2Short(&m_wVersion, pcData+2);
	g_Mem2Long(&m_dwDataID, pcData+4);
	g_Mem2Short(&m_wDataType, pcData+8);
	g_Mem2Short(&m_wDataSubType, pcData+10);
	g_Mem2Long(&m_dwDataLength, pcData+12);

	return _DataHeadOldLength_;
}

u_long CDataHeadOld::Send(char* pcData)
{
	g_Short2Mem(pcData, &m_wHeadID);
	g_Short2Mem(pcData+2, &m_wVersion);
	g_Long2Mem(pcData+4, &m_dwDataID);
	g_Short2Mem(pcData+8, &m_wDataType);
	g_Short2Mem(pcData+10, &m_wDataSubType);
	g_Long2Mem(pcData+12, &m_dwDataLength);
	free(pcData+16);

	return _DataHeadOldLength_;
}
