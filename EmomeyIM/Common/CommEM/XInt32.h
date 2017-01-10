
#include <stdio.h>
#include <UIKit/UIKit.h>
class  XInt32
{
public:
	XInt32();
	XInt32(const int64_t n);

	static int32_t	m_nMaxBase;
	static int32_t	m_nMinBase;
	static Byte		m_cMaxMul;

	int 			m_nBase:29;
	unsigned int	m_cMul:3;

	int64_t GetValue();
	operator int64_t() { return GetValue();}

	XInt32 operator=(const int32_t x);

	XInt32 operator=(const int64_t n);
	XInt32 operator+=(const int64_t n);

	int32_t GetRawData();
	void SetRawData(int32_t n);

	BOOL operator==(XInt32 x);
};

typedef XInt32*  PXInt32;
