
#include <UIKit/UIKit.h>

#include <stdio.h>


#pragma pack(push, 1)

class CDataHeadOld;

//////////////////////////////////////////////////////////////////////

class  CDataHead
{
public:
	CDataHead();
	CDataHead(CDataHeadOld&);

	void Initial();
	uint32_t Recv(char*);
	uint32_t Send(char*);

public:
	ushort m_wHeadID;
	ushort m_wDataType;
	uint32_t m_dwDataID;
	uint32_t m_dwDataLength;
	ushort m_wChecksum;
	ushort m_wReserved;
};

////////////////////////////////////////////////////////////////////

class  CDataHeadOld
{
public:
	CDataHeadOld();
	CDataHeadOld(CDataHead&);

	void Initial();
	u_long Recv(char*);
	u_long Send(char*);

public:
	ushort m_wHeadID;
	ushort m_wVersion;
	uint32_t m_dwDataID;
	ushort m_wDataType;					//  ˝æ›¿‡–Õ, 0:…æ≥˝m_ulDataID∂‘”¶µƒ ˝æ›
	ushort m_wDataSubType;				//  ˝æ›◊”¿‡–Õ, ‘› ±Œ™0
    uint32_t m_dwDataLength;				//  ˝æ›∞¸≥§∂»(≤ªÀ„∞¸Õ∑)
	ushort m_wEncryptType;				// º”√‹∑Ω∑®, 0:Œﬁº”√‹;
	uint32_t m_dwEncryptLength;			// º”√‹≥§∂».
	Byte m_cStatus;						// ±Í÷æŒª.
	char m_pcReserve[9];				// 
};										// “ªπ≤32∏ˆ◊÷Ω⁄.

#pragma pack(pop)

#define _DataHeadLength_	16
#define _DataHeadOldLength_	32
