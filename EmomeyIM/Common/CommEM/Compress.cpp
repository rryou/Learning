// Compress.cpp: implementation of the CCompress class.
//
//////////////////////////////////////////////////////////////////////

#include "Compress.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

unsigned char p_len[64] = {
	0x03, 0x04, 0x04, 0x04, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
};

unsigned char p_code[64] = {
	0x00, 0x20, 0x30, 0x40, 0x50, 0x58, 0x60, 0x68,
	0x70, 0x78, 0x80, 0x88, 0x90, 0x94, 0x98, 0x9C,
	0xA0, 0xA4, 0xA8, 0xAC, 0xB0, 0xB4, 0xB8, 0xBC,
	0xC0, 0xC2, 0xC4, 0xC6, 0xC8, 0xCA, 0xCC, 0xCE,
	0xD0, 0xD2, 0xD4, 0xD6, 0xD8, 0xDA, 0xDC, 0xDE,
	0xE0, 0xE2, 0xE4, 0xE6, 0xE8, 0xEA, 0xEC, 0xEE,
	0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
	0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
};

unsigned char d_code[256] = {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02,
	0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
	0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09,
	0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A,
	0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B,
	0x0C, 0x0C, 0x0C, 0x0C, 0x0D, 0x0D, 0x0D, 0x0D,
	0x0E, 0x0E, 0x0E, 0x0E, 0x0F, 0x0F, 0x0F, 0x0F,
	0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x11,
	0x12, 0x12, 0x12, 0x12, 0x13, 0x13, 0x13, 0x13,
	0x14, 0x14, 0x14, 0x14, 0x15, 0x15, 0x15, 0x15,
	0x16, 0x16, 0x16, 0x16, 0x17, 0x17, 0x17, 0x17,
	0x18, 0x18, 0x19, 0x19, 0x1A, 0x1A, 0x1B, 0x1B,
	0x1C, 0x1C, 0x1D, 0x1D, 0x1E, 0x1E, 0x1F, 0x1F,
	0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23,
	0x24, 0x24, 0x25, 0x25, 0x26, 0x26, 0x27, 0x27,
	0x28, 0x28, 0x29, 0x29, 0x2A, 0x2A, 0x2B, 0x2B,
	0x2C, 0x2C, 0x2D, 0x2D, 0x2E, 0x2E, 0x2F, 0x2F,
	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
	0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F,
};

unsigned char d_len[256] = {
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
};

const int MAX_OUTBUF_LEN = 0x10000000;		//100M

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CCompress::CCompress()
{
	m_wGetBuf = 0;
	m_byGetLen = 0;
	m_wPutBuf = 0;
	m_byPutLen = 0;

	m_lIn = 0;
	m_pcIn = NULL;
	m_lOut = 0;
	m_pcOut = NULL;

	m_lLenOfOutBuf = 0;
	m_cOutType = 0;
}

CCompress::~CCompress()
{
	FreeOut();
}

BOOL CCompress::Decode()
{
	int32_t lSize = *((int32_t *)m_pcIn);
	if(lSize <= 0 || lSize > MAX_OUTBUF_LEN)
		return FALSE;

	if(m_pcOut != NULL && m_lLenOfOutBuf < lSize)
		FreeOut();

	if (m_pcOut == NULL)
	{
		m_lLenOfOutBuf = lSize;
		m_pcOut = AllocOut(m_lLenOfOutBuf, m_cOutType);
	}

	if (m_pcOut == NULL)
		return FALSE;
    
    memset(m_pcOut, 0,m_lLenOfOutBuf );

	m_lInCount = 4;
	m_lOutCount = 0;
	m_wGetBuf = 0;
	m_byGetLen = 0;
	
	StartHuff();

	short nR = _LZH_N - _LZH_F;
	memset(m_pbyBuffer, ' ', nR);

	for (m_lOutCount = 0; m_lOutCount < lSize; ) 
	{
		short nC = DecodeChar();
		if (nC < 256) 
		{
			CheckOutBuff(m_lOutCount);
			m_pcOut[m_lOutCount++] = (char)nC;
			m_pbyBuffer[nR++] = (char)nC;
			nR &= (_LZH_N - 1);
		} 
		else 
		{
			int i = (nR - DecodePosition() - 1) & (_LZH_N - 1);
			int j = nC - 255 + _LZH_THRESHOLD;
			for (int k = 0; k < j; k++) 
			{
				nC = m_pbyBuffer[(i + k) & (_LZH_N - 1)];
				CheckOutBuff(m_lOutCount);
				m_pcOut[m_lOutCount++] = (char)nC;
				m_pbyBuffer[nR++] = (char)nC;
				nR &= (_LZH_N - 1);
			}
		}
	}
	m_lOut = m_lOutCount;
	return TRUE;
}

void CCompress::StartHuff()
{
	for (int i = 0; i < _LZH_N_CHAR; i++) 
	{
		m_pwFreq[i] = 1;
		m_pnSon[i] = i+_LZH_T;
		m_pnParent[i+_LZH_T] = i;
	}
    int i = 0;
	int j = _LZH_N_CHAR;
	while (j <= _LZH_R) 
	{
		m_pwFreq[j] = m_pwFreq[i] + m_pwFreq[i+1];
		m_pnSon[j] = i;
		m_pnParent[i] = m_pnParent[i+1] = j;
		i += 2; 
		j++;
	}
	m_pwFreq[_LZH_T] = 0xffff;
	m_pnParent[_LZH_R] = 0;
}

short CCompress::DecodeChar()
{
	ushort c = m_pnSon[_LZH_R];
	while (c < _LZH_T) 
	{
		c += GetBit();
		c = m_pnSon[c];
	}
	c -= _LZH_T;
	Update(c);
	return c;
}

short CCompress::DecodePosition()
{
	ushort i = GetByte();
	ushort c = (ushort)d_code[i] << 6;
	ushort j = d_len[i] - 2;
	while (j--)
		i = (i << 1) + GetBit();
	return c | (i & 0x3f);
}

short CCompress::GetBit(){
	short i;
	while (m_byGetLen <= 8) 
	{
		if (m_lInCount < m_lIn)
			i = (Byte)m_pcIn[m_lInCount++];
		else
			i = 0;
		m_wGetBuf |= i << (8 - m_byGetLen);
		m_byGetLen += 8;
	}
	i = m_wGetBuf;
	m_wGetBuf <<= 1;
	m_byGetLen -= 1;
	return (i < 0);
}

short CCompress::GetByte(){
	ushort i;
	while (m_byGetLen <= 8) 
	{
		if (m_lInCount < m_lIn)
			i = (Byte)m_pcIn[m_lInCount++];
		else
			i = 0;
		m_wGetBuf |= i << (8 - m_byGetLen);
		m_byGetLen += 8;
	}
	i = m_wGetBuf;
	m_wGetBuf <<= 8;
	m_byGetLen -= 8;
	return i >> 8;
}

void CCompress::Update(short c)
{
	short i, j, k, l;

	if (m_pwFreq[_LZH_R] == _LZH_MAX_FREQ) 
		ReConstruct();
	c = m_pnParent[c + _LZH_T];
	do 
	{
		k = ++m_pwFreq[c];

		if (k > m_pwFreq[l = c + 1]) 
		{
			while (k > m_pwFreq[++l])
				;
			l--;
			m_pwFreq[c] = m_pwFreq[l];
			m_pwFreq[l] = k;

			i = m_pnSon[c];
			m_pnParent[i] = l;
			if (i < _LZH_T)
				m_pnParent[i + 1] = l;

			j = m_pnSon[l];
			m_pnSon[l] = i;

			m_pnParent[j] = c;
			if (j < _LZH_T) 
				m_pnParent[j + 1] = c;
			m_pnSon[c] = j;

			c = l;
		}
	} while ((c = m_pnParent[c]) != 0);	/* do it until reaching the root */
}

void CCompress::ReConstruct()
{
	short i, j, k;
	ushort f, l;

	j = 0;
	for (i = 0; i < _LZH_T; i++) 
	{
		if (m_pnSon[i] >= _LZH_T) 
		{
			m_pwFreq[j] = (m_pwFreq[i] + 1) / 2;
			m_pnSon[j] = m_pnSon[i];
			j++;
		}
	}
	for (i = 0, j = _LZH_N_CHAR; j < _LZH_T; i += 2, j++) 
	{
		k = i + 1;
		f = m_pwFreq[j] = m_pwFreq[i] + m_pwFreq[k];
		for (k = j - 1; f < m_pwFreq[k]; k--)
			;
		k++;
		l = (j - k) * 2;
		
		memmove(&m_pwFreq[k + 1], &m_pwFreq[k], l);
		m_pwFreq[k] = f;
		memmove(&m_pnSon[k + 1], &m_pnSon[k], l);
		m_pnSon[k] = i;
	}
	for (i = 0; i < _LZH_T; i++) 
	{
		if ((k = m_pnSon[i]) >= _LZH_T) 
			m_pnParent[k] = i;
		else
			m_pnParent[k] = m_pnParent[k + 1] = i;
	}
}

BOOL CCompress::Encode()
{
	if(m_lIn <= 0 || m_pcIn == NULL)
		return FALSE;

	try
	{
		short i, c, len, r, s, last_match_length;

		if(m_pcOut != NULL && (m_lLenOfOutBuf < m_lIn + 2048))
			FreeOut();

		if(m_pcOut == NULL)
		{
			m_lLenOfOutBuf = m_lIn + 2048;
			m_pcOut = AllocOut(m_lLenOfOutBuf, m_cOutType);
		}

		if (m_pcOut == NULL)
			return FALSE;
        memset(m_pcOut, 0, m_lLenOfOutBuf);
		*(SInt32*)m_pcOut = m_lIn;
	
		m_lInCount = 0;
		m_lOutCount = 4;
		m_wPutBuf = 0;
		m_byPutLen = 0;

		StartHuff();
		InitTree();
	
		s = 0;
		r = _LZH_N - _LZH_F;
		memset(m_pbyBuffer, ' ', r);
	
		for (len = 0; len < _LZH_F && m_lInCount < m_lIn; len++)
			m_pbyBuffer[r + len] = (Byte)m_pcIn[m_lInCount++];
		for (i = 1; i <= _LZH_F; i++)
			InsertNode(r - i);
		InsertNode(r);
		do 
		{
			if (m_nMatchLen > len)
				m_nMatchLen = len;
			if (m_nMatchLen <= _LZH_THRESHOLD) 
			{
				m_nMatchLen = 1;
				EncodeChar(m_pbyBuffer[r]);
			} 
			else 
			{
				EncodeChar(255 - _LZH_THRESHOLD + m_nMatchLen);
				EncodePosition(m_nMatchPos);
			}
			last_match_length = m_nMatchLen;
			for (i = 0; i < last_match_length && m_lInCount < m_lIn; i++) 
			{
				DeleteNode(s);
				c = (Byte)m_pcIn[m_lInCount++];
				m_pbyBuffer[s] = (Byte)c;
				if (s < _LZH_F - 1)
					m_pbyBuffer[s + _LZH_N] = (Byte)c;
				s = (s + 1) & (_LZH_N - 1);
				r = (r + 1) & (_LZH_N - 1);
				InsertNode(r);
			}
			while (i++ < last_match_length) 
			{
				DeleteNode(s);
				s = (s + 1) & (_LZH_N - 1);
				r = (r + 1) & (_LZH_N - 1);
				if (--len) 
					InsertNode(r);
			}
		} while (len > 0);
		EncodeEnd();
		m_lOut = m_lOutCount;

		return TRUE;
	}
	catch(...)
	{
	}
	return FALSE;
}

void CCompress::InitTree()
{
	for (int i = _LZH_N + 1; i <= _LZH_N + 256; i++)
		m_pnRightSon[i] = _LZH_NIL;
	for ( int i = 0; i < _LZH_N; i++)
		m_pnDad[i] = _LZH_NIL;
}

void CCompress::InsertNode(short r)
{
	short i, p, cmp;
	Byte *key;
	ushort c;

	cmp = 1;
	key = &m_pbyBuffer[r];
	p = _LZH_N + 1 + key[0];
	m_pnRightSon[r] = m_pnLeftSon[r] = _LZH_NIL;
	m_nMatchLen = 0;
	for ( ; ; ) 
	{
		if (cmp >= 0) 
		{
			if (m_pnRightSon[p] != _LZH_NIL)
				p = m_pnRightSon[p];
			else 
			{
				m_pnRightSon[p] = r;
				m_pnDad[r] = p;
				return;
			}
		} 
		else 
		{
			if (m_pnLeftSon[p] != _LZH_NIL)
				p = m_pnLeftSon[p];
			else 
			{
				m_pnLeftSon[p] = r;
				m_pnDad[r] = p;
				return;
			}
		}
		for (i = 1; i < _LZH_F; i++)
			if ((cmp = key[i] - m_pbyBuffer[p + i]) != 0)
				break;
		if (i > _LZH_THRESHOLD) 
		{
			if (i > m_nMatchLen) 
			{
				m_nMatchPos = ((r - p) & (_LZH_N - 1)) - 1;
				if ((m_nMatchLen = i) >= _LZH_F)
					break;
			}
			if (i == m_nMatchLen) 
			{
				if ((c = ((r - p) & (_LZH_N - 1)) - 1) < m_nMatchPos)
					m_nMatchPos = c;
			}
		}
	}
	m_pnDad[r] = m_pnDad[p];
	m_pnLeftSon[r] = m_pnLeftSon[p];
	m_pnRightSon[r] = m_pnRightSon[p];
	m_pnDad[m_pnLeftSon[p]] = r;
	m_pnDad[m_pnRightSon[p]] = r;
	if (m_pnRightSon[m_pnDad[p]] == p)
		m_pnRightSon[m_pnDad[p]] = r;
	else
		m_pnLeftSon[m_pnDad[p]] = r;
	m_pnDad[p] = _LZH_NIL;  /* remove p */
}

void CCompress::DeleteNode(short p)
{
	short q;

	if (m_pnDad[p] == _LZH_NIL)
		return;			/* unregistered */
	if (m_pnRightSon[p] == _LZH_NIL)
		q = m_pnLeftSon[p];
	else
	if (m_pnLeftSon[p] == _LZH_NIL)
		q = m_pnRightSon[p];
	else 
	{
		q = m_pnLeftSon[p];
		if (m_pnRightSon[q] != _LZH_NIL) 
		{
			do 
			{
				q = m_pnRightSon[q];
			} while (m_pnRightSon[q] != _LZH_NIL);
			m_pnRightSon[m_pnDad[q]] = m_pnLeftSon[q];
			m_pnDad[m_pnLeftSon[q]] = m_pnDad[q];
			m_pnLeftSon[q] = m_pnLeftSon[p];
			m_pnDad[m_pnLeftSon[p]] = q;
		}
		m_pnRightSon[q] = m_pnRightSon[p];
		m_pnDad[m_pnRightSon[p]] = q;
	}
	m_pnDad[q] = m_pnDad[p];
	if (m_pnRightSon[m_pnDad[p]] == p)
		m_pnRightSon[m_pnDad[p]] = q;
	else
		m_pnLeftSon[m_pnDad[p]] = q;
	m_pnDad[p] = _LZH_NIL;
}

void CCompress::EncodeChar(ushort c)
{
	ushort i;
	short j, k;

	i = 0;
	j = 0;
	k = m_pnParent[c + _LZH_T];

	do 
	{
		i >>= 1;
		if (k & 1) 
			i += 0x8000;
		j++;
	} while ((k = m_pnParent[k]) != _LZH_R);
	PutCode(j, i);
	m_wCode = i;
	m_wLen = j;
	Update(c);
}

void CCompress::EncodePosition(ushort c)
{
	ushort i;

	i = c >> 6;
	PutCode(p_len[i], (ushort)p_code[i] << 8);
	PutCode(6, (c & 0x3f) << 10);
}

void CCompress::EncodeEnd()
{
    if (m_byPutLen)
	{
		CheckOutBuff(m_lOutCount);
		m_pcOut[m_lOutCount++] = m_wPutBuf >> 8;
	}
}

void CCompress::PutCode(short l, ushort c)
{
	m_wPutBuf |= c >> m_byPutLen;
	if ((m_byPutLen += l) >= 8) 
	{
		CheckOutBuff(m_lOutCount);
		m_pcOut[m_lOutCount++] = m_wPutBuf >> 8;
		if ((m_byPutLen -= 8) >= 8) 
		{
			CheckOutBuff(m_lOutCount);
			m_pcOut[m_lOutCount++] = (char)m_wPutBuf;
			m_byPutLen -= 8;
			m_wPutBuf = c << (l - m_byPutLen);
		} 
		else 
			m_wPutBuf <<= 8;
	}
}

BOOL CCompress::CheckOutBuff(int nCurPos)
{
	if(nCurPos < m_lLenOfOutBuf)
		return TRUE;

	int nNewLen = m_lLenOfOutBuf;
	while (nCurPos >= nNewLen)
		nNewLen += 1024;

	char cType = 0;
	char* pcNewOut = AllocOut(nNewLen, cType);
	if (pcNewOut==NULL)
		return FALSE;
    free(pcNewOut);
    memset(pcNewOut, 0, nNewLen);

	if (m_pcOut != NULL)
	{
        memcpy(pcNewOut, m_pcOut, m_lLenOfOutBuf);
		FreeOut();
	}

	m_pcOut = pcNewOut;
	m_cOutType = cType;
	m_lLenOfOutBuf = nNewLen;

	return TRUE;
}

char* CCompress::AllocOut(uint32_t dwNum, char& cType)
{
	char* pcOut = NULL;
    pcOut = (char *)malloc(dwNum);
//   pcOut = (char*)VirtualAlloc(NULL, dwNum, MEM_COMMIT, PAGE_READWRITE);
    cType = 0;
	return pcOut;
}

void CCompress::FreeOut()
{
	if (m_pcOut)
	{
		if (m_cOutType==0)
            free(m_pcOut);
	}
	m_pcOut = NULL;
	m_lLenOfOutBuf = 0;
}
