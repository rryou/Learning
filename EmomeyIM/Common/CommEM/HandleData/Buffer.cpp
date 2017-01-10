// Buffer.cpp: implementation of the CBuffer class.
//
//////////////////////////////////////////////////////////////////////

#include "Buffer.h"
#import "EMTypeConversion.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//#include "stock_trade_rsa_encrypt.h"
uint32_t	CBuffer::m_dwPageSize = 1;

CBuffer::CBuffer()
{
	m_nSize = 0;

	m_bSustainSize = false;
	m_bSingleRead = false;
	m_bNoAlloc = false;
	m_nReadPos = 0;

	m_pBase =  NULL;
	m_nDataSize = 0;

	m_nInitSize = 0;
	m_nMoreBytes = 0;
}

void CBuffer::Initialize(uint nInitsize, bool bSustain, uint nMoreBytes)
{

	m_bSustainSize = bSustain;
	m_nMoreBytes = nMoreBytes;

	ReAllocateBuffer(nInitsize);
	m_nInitSize = m_nSize;
}


CBuffer::~CBuffer()
{
	if (m_bNoAlloc)
		return;

	if (m_pBase)
		FreeBuffer(m_pBase);
}
	

uint CBuffer::GetMemSize()
{
	return m_nSize;
}

uint CBuffer::GetBufferLen()
{
	if(m_pBase == NULL)
		return 0;

	if (m_bSingleRead==true)
		return m_nDataSize-m_nReadPos;
	else
		return m_nDataSize;
}

Byte *CBuffer::GetBuffer(uint nPos)
{
	if(m_pBase == NULL)
		return NULL;

	return m_pBase + nPos;
}

uint CBuffer::ReAllocateBuffer(uint nRequestedSize)
{
	if (m_bNoAlloc)
		return 0;

	if(nRequestedSize <= m_nSize)
		return 0;

	uint nNewSize = m_nSize;
	if(nNewSize < m_dwPageSize)
		nNewSize = m_dwPageSize;

	while(nRequestedSize > nNewSize)
		nNewSize *= 2;

//    if (m_nDataSize < nNewSize) {
//        return  0;
//    }
	// New Copy Data Over
	Byte *pNewBuffer = (Byte *) AllocBuffer(nNewSize);
	if (m_pBase)
	{
		if(m_nDataSize)
            memcpy(pNewBuffer, m_pBase, m_nDataSize);
		FreeBuffer(m_pBase);
	}

	// Hand over the pointer
	m_pBase = pNewBuffer;

	m_nSize = nNewSize;

//	TRACE("ReAllocateBuffer %d\n",m_nSize);

	return m_nSize;
}


uint CBuffer::DeAllocateBuffer(uint nRequestedSize)
{
	if (m_bNoAlloc)
		return 0;

    if (m_nSize<=0) {
        return 0;
    }

	if(m_bSustainSize)
		return 0;

	if(m_nSize <= m_nInitSize)
		return 0;

	if(nRequestedSize < m_nDataSize)
		return 0;

	if(nRequestedSize < m_nInitSize)
		nRequestedSize = m_nInitSize;

	uint nNewSize = m_nSize;
	while(nNewSize >= nRequestedSize * 2)
		nNewSize /= 2;

	if(nNewSize == m_nSize)
		return 0;
    if (m_nDataSize <= nNewSize) {
        return 0;
    }
    
	Byte *pNewBuffer = (Byte *) AllocBuffer(nNewSize);
	if (m_pBase)
	{
		if(m_nDataSize)
            memcpy(pNewBuffer, m_pBase, m_nDataSize);

		FreeBuffer(m_pBase);
	}

	// Hand over the pointer
	m_pBase = pNewBuffer;
	m_nSize = nNewSize;
//	TRACE("DeAllocateBuffer %d\n",m_nSize);
	return m_nSize;
}

uint CBuffer::Add(uint nSize)
{
	if (nSize)
	{
		ReAllocateBuffer(nSize + m_nDataSize + m_nMoreBytes);

		// Advance Pointer
		m_nDataSize += nSize;
	}

	return nSize;
}

uint CBuffer::Write(const void* pData, uint nSize)
{
	if(nSize)
	{
		ReAllocateBuffer(nSize + m_nDataSize + m_nMoreBytes);
      
		memcpy(m_pBase+m_nDataSize, pData, nSize);
        
		m_nDataSize += nSize;
	}
                                                                  
	return nSize;
}

uint CBuffer::Insert(const void* pData, uint nSize)
{
	ReAllocateBuffer(nSize + m_nDataSize + m_nMoreBytes);

	memmove(m_pBase+nSize, m_pBase, m_nDataSize);
	memcpy(m_pBase, pData, nSize);

	// Advance Pointer
	m_nDataSize += nSize;

	return nSize;
}

uint CBuffer::Read(void* pData, uint nSize)
{
	// all that we have 
		
	if (nSize)
	{
		if (m_bSingleRead)
		{
			if (nSize+m_nReadPos > m_nDataSize)
			{
				throw DATA_LACK;
				return 0;
			}

			memcpy(pData, m_pBase+m_nReadPos, nSize);
			m_nReadPos += nSize;
		}
		else
		{
			if (nSize > m_nDataSize)
			{
				throw DATA_LACK;
				return 0;
			}

			m_nDataSize -= nSize;

			memcpy(pData, m_pBase, nSize);
			if (m_nDataSize > 0)
				memmove(m_pBase, m_pBase+nSize, m_nDataSize);
		}
	}
	DeAllocateBuffer(m_nDataSize + m_nMoreBytes);
	return nSize;
}

uint CBuffer::SkipData(int nSize){
    if (m_bSingleRead) {
        return 0;
    }
	if(m_bSingleRead)
	{
		if (nSize+m_nReadPos > m_nDataSize)
		{
			throw DATA_LACK;
			return 0;
		}

		m_nReadPos += nSize;
		return nSize;
	}
	return 0;
}

void CBuffer::ClearBuffer(){
	// Force the buffer to be empty
	m_nDataSize = 0;
	m_nReadPos = 0;

	DeAllocateBuffer(0);
}

void CBuffer::Copy(CBuffer& buffer)
{
	uint nReSize = buffer.GetMemSize();

	if(nReSize != m_nSize)
	{
		if (m_pBase)
			FreeBuffer(m_pBase);
		m_pBase = (Byte *) AllocBuffer(nReSize);

		m_nSize = nReSize;
	}
	m_nDataSize = buffer.GetBufferLen();

	if(m_nDataSize > 0)
		memcpy(m_pBase, buffer.GetBuffer(), m_nDataSize);
}

void CBuffer::FileWrite(NSString* strFileName){
	if(m_pBase == NULL || m_nDataSize == 0)
    return;
    NSData *temdata = [[NSData alloc] initWithBytes:m_pBase length:m_nDataSize];
    [temdata writeToFile:strFileName atomically:YES];
}

void CBuffer::FileRead( NSString* strFileName){
    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:strFileName];
    NSData *filedata = [fh readDataToEndOfFile];
    char* pcFileData = NULL;
    int32_t dwLength = (int32_t)filedata.length;
    pcFileData = new char[dwLength];
    memcpy(pcFileData, filedata.bytes, dwLength);
    Write(pcFileData, dwLength);
    delete[] pcFileData;
}

uint CBuffer::Delete(uint nSize)
{
	if(nSize == 0)
		return nSize;

	if (nSize > m_nDataSize)
		nSize = m_nDataSize;

	m_nDataSize -= nSize;

	if(m_nDataSize > 0)
		memmove(m_pBase, m_pBase+nSize, m_nDataSize);
		
	DeAllocateBuffer(m_nDataSize);
	return nSize;
}

const CBuffer& CBuffer::operator+(CBuffer& buff)
{
	this->Write(buff.GetBuffer(), buff.GetBufferLen());

	return* this;
}

uint CBuffer::DeleteEnd(uint nSize)
{
	if(nSize > m_nDataSize)
		nSize = m_nDataSize;
		
	if(nSize)
	{
		m_nDataSize -= nSize;
		DeAllocateBuffer(m_nDataSize);
	}
		
	return nSize;
}

uint CBuffer::Rollback(uint nDataSizeNew)
{
	m_nDataSize = nDataSizeNew;
	DeAllocateBuffer(m_nDataSize);
	
	return nDataSizeNew;
}

void CBuffer::SetBuffer(Byte *pData, uint uSize)
{
	m_bNoAlloc = true;
	m_pBase = pData;
	m_nDataSize = m_nSize = uSize;
}

void CBuffer::WriteChar(char cValue)
{
	Write(&cValue, 1);
}

char CBuffer::ReadChar()
{
	char cValue;
	Read(&cValue, 1);
	return cValue;
}

void CBuffer::WriteShort(short sValue)
{
	Write(&sValue, 2);
}

short CBuffer::ReadShort()
{
	short sValue;
	Read(&sValue, 2);
	return sValue;
}

void CBuffer::WriteInt(int nValue)
{
	Write(&nValue, 4);
}

int32_t CBuffer::ReadInt()
{
	int32_t nValue;
	Read(&nValue, 4);
	return nValue;
}

void CBuffer::WriteXInt(XInt32 xValue)
{
	WriteInt(xValue.GetRawData());
}

XInt32 CBuffer::ReadXInt()
{
	XInt32 xValue;
	xValue.SetRawData(ReadInt());
	return xValue;
}

void CBuffer::WriteLong(int64_t hValue){
    int32_t Highpart =int32_t (hValue>>32);
    int32_t lowPart = int32_t(hValue&0xffffffff);
	WriteInt(Highpart);
	WriteInt(lowPart);
}

int64_t CBuffer::ReadLong()
{
    int64_t Highpart = ReadInt();
    int64_t lowPart = ReadInt();
	return (Highpart<<32) + lowPart;
}

NSString *CBuffer::ReadString(){
    NSMutableData *tempdata =  [[NSMutableData alloc] init];
	ushort wSize = ReadShort();
	if (wSize>0)
	{
        ReadString(tempdata,(uint32_t)wSize);
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString*pageSource = [[NSString alloc] initWithData:tempdata encoding:gbkEncoding];
        if (pageSource) {
            return pageSource;
        }else{
            return @"编码问题";
        }
	}
   return  [EMTypeConversion NSDataConvertVChar:tempdata];
}

uint CBuffer::ReadString(NSData* strData){
    strData = nil;

	ushort wSize = ReadShort();
	if (wSize>0){
		if (ReadString(strData, (u_long)wSize)==FALSE)
			return 2;
	}
	return uint(wSize+2);
}

uint CBuffer::WriteString(NSString *strData)
{
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
     NSData *tempDate = [strData dataUsingEncoding:gbkEncoding];
    const char *ch =(const char *)[tempDate bytes];
    ushort wSize =  tempDate.length;
	WriteShort(wSize);
	if(wSize)
		Write(ch, wSize);
	return (uint)(wSize+2);
}

NSString *CBuffer::ReadStringLong(){
    NSMutableData *strdata = [NSMutableData data];
	ushort dwSize = ReadInt();
	if (dwSize>0){
        ReadString(strdata, dwSize);
	}

	return [EMTypeConversion NSDataConvertNSString:strdata];
}

uint CBuffer::ReadStringLong(NSData *strData)
{
	strData = nil;

	u_long dwSize = ReadInt();
	if (dwSize>0)
	{
		if (ReadString(strData, dwSize)==FALSE)
			return 4;
	}

	return uint(dwSize+4);
}

uint CBuffer::WriteStringLong(NSData *strData)
{
	u_long dwSize = strData.length;
	WriteLong(dwSize);

    if (dwSize){
      void *p = (__bridge_retained void *)strData;
		Write(p, dwSize);
    }
	
	return (uint)(dwSize+4);
}

NSString *CBuffer::ReadStringShort(){
	Byte bSize = ReadChar();
    NSMutableData *strData = [NSMutableData data];
	if (bSize){
        ReadString(strData, (uint32_t)bSize);
        char *tempStr = ( char *)[strData mutableBytes];
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString*pageSource = [[NSString alloc] initWithData:strData encoding:gbkEncoding];
        return pageSource;
	}
	NSString *result =  [EMTypeConversion NSDataConvertVChar:strData];
    NSLog(@"%@", result);
    return result;
}

uint CBuffer::ReadStringShort(NSString* strData){
	strData = @"";
	Byte bSize = ReadChar();
	if (bSize){
		if (ReadString([EMTypeConversion NSStringConvertNSData:strData], (u_long)bSize)==FALSE)
			return 1;
	}
	return uint(bSize+1);
}

uint CBuffer::WriteStringShort(NSString *strData){
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *tempDate = [strData dataUsingEncoding:gbkEncoding];
    const char *ch =(const char *)[tempDate bytes];
    char wSize =  tempDate.length;
    WriteChar(wSize);
    if(wSize)
        Write(ch, wSize);
    return (uint)(wSize+1);
}

BOOL CBuffer::ReadString(NSMutableData* strData, uint32_t dwSize)
{
    Byte p_tempByte[dwSize];
    
	if (m_bSingleRead){
		if (dwSize+m_nReadPos > m_nDataSize)
		{
			throw DATA_LACK;
			return FALSE;
		}
        memcpy(p_tempByte, m_pBase+m_nReadPos , dwSize);
		m_nReadPos += dwSize;
	}
	else
	{
		memcpy(p_tempByte, m_pBase, dwSize);
		Delete(dwSize);
	}
    [strData appendBytes:p_tempByte length:dwSize];
    return true;
}
