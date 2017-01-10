

#include <UIKit/UIKit.h>

#define _LZH_N			4096
#define _LZH_F			60
#define _LZH_THRESHOLD	2
#define _LZH_NIL		_LZH_N
#define _LZH_N_CHAR  	(256 - _LZH_THRESHOLD + _LZH_F)
#define _LZH_T	 		(_LZH_N_CHAR * 2 - 1)
#define _LZH_R 			(_LZH_T - 1)
#define _LZH_MAX_FREQ	0x8000
#define MEM_COMMIT      0X1000
#define PAGE_READWRITE  0X04


class  CCompress
{
public:
	CCompress();
	virtual ~CCompress();

	BOOL Encode();
	BOOL Decode();

public:
	char * m_pcIn;
	int32_t m_lIn;
	char * m_pcOut;
	int32_t m_lOut;
	char m_cOutType;

private:
	int32_t m_lInCount;
	int32_t m_lOutCount;
	Byte m_pbyBuffer[_LZH_N + _LZH_F - 1];
	short m_nMatchPos;
	short m_nMatchLen;
	short m_pnLeftSon[_LZH_N + 1];
	short m_pnRightSon[_LZH_N + 257];
	short m_pnDad[_LZH_N + 1];
	ushort m_pwFreq[_LZH_T + 1];
	short m_pnParent[_LZH_T + _LZH_N_CHAR];
	short m_pnSon[_LZH_T];
	ushort m_wGetBuf;
	Byte m_byGetLen;
	ushort m_wPutBuf;
	Byte m_byPutLen;
	ushort m_wCode;
	ushort m_wLen;
	int32_t m_lLenOfOutBuf;

	void StartHuff();
	short DecodeChar();
	short DecodePosition();
	short GetBit();
	short GetByte();
	void Update(short);
	void ReConstruct();
	void InitTree();
	void InsertNode(short);
	void DeleteNode(short);
	void EncodeChar(ushort);
	void EncodePosition(ushort);
	void EncodeEnd();
	void PutCode(short, ushort);

	BOOL CheckOutBuff(int nCurPos);

	char* AllocOut(uint32_t dwNum, char& cType);
	void FreeOut();
};
