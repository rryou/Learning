#include "XInt32.h"
#include <stdio.h>
#include <UIKit/UIKit.h>

#define		BUFFER_PAGE_SIZE		65536

#define		DATA_LACK				-1
#define		DATA_ERROR				-2
typedef union _LARGE_INTEGER {
    struct {
        uint32_t LowPart;
        long HighPart;
    } DUMMYSTRUCTNAME;
    struct {
        uint32_t LowPart;
        long HighPart;
    } u;
    long QuadPart;
} LARGE_INTEGER;
    
    class CBuffer
{
// Attributes
protected:
	Byte		*m_pBase;
	uint		m_nDataSize;
	uint		m_nSize;

	uint		m_nInitSize;

	uint		m_nMoreBytes;

	bool		m_bSustainSize;

	static uint32_t		m_dwPageSize;

public:
	bool		m_bNoAlloc;		//≤ª∑÷≈‰ƒ⁄¥Ê
	bool		m_bSingleRead;
	uint		m_nReadPos;
// Methods
protected:
	uint DeAllocateBuffer(uint nRequestedSize);
	uint GetMemSize();

public:
	CBuffer();
	virtual ~CBuffer();

	void ClearBuffer();
	void Initialize(uint nInitsize, bool bSustain, uint nMoreBytes = 0);

	uint Delete(uint nSize);
	uint Add(uint nSize);
	uint Read(void* pData, uint nSize);
	uint Write(const void* pData, uint nSize);
	uint Insert(const void* pData, uint nSize);
	uint DeleteEnd(uint nSize);
	uint Rollback(uint nDataSizeNew);

	uint SkipData(int nSize);

	void Copy(CBuffer& buffer);	

	Byte *GetBuffer(uint nPos=0);
	uint GetBufferLen();

	const CBuffer& operator+(CBuffer& buff);
	uint ReAllocateBuffer(uint nRequestedSize);

	void SetBuffer(Byte *, uint);

	void WriteChar(char);
	char ReadChar();
	void WriteShort(short);
	short ReadShort();
	void WriteInt(int);
	int ReadInt();
	void WriteXInt(XInt32);
	XInt32 ReadXInt();
	void WriteLong(int64_t);
	int64_t ReadLong();
    
    void FileWrite(NSString* strFileName);
	NSString *ReadString();
	NSString *ReadStringLong();
	NSString *ReadStringShort();
    void FileRead(NSString* strFileName);
	uint ReadString(NSData *);
	uint ReadStringLong(NSData*);
	uint ReadStringShort(NSString*);

	uint WriteString(NSString *);
	uint WriteStringLong(NSData*);
	uint WriteStringShort(NSString*);
protected:
	BOOL ReadString(NSMutableData * strData, uint32_t dwSize);

private:
	void* AllocBuffer(uint32_t dwNum)
	{
		void* p = NULL;
        p = malloc(dwNum);
		return p;
	}

	void FreeBuffer(void* p)
	{
        free(p);
	}
};
