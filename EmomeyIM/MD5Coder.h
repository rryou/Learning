#import <UIKit/UIKit.h>

class CMD5Coder  
{
public:
	static void EncodeMD5Raw(Byte* pcValue, int32_t dwLength, char pcHash[16]);
	static void EncodeMD5(Byte* pcValue, int32_t dwLength, char pcDest[33]);

private:
	static int32_t F(int32_t X, int32_t Y, int32_t Z)
	{
		return (X & Y) | ((~X) & Z);
	}

	static int32_t G(int32_t X, int32_t Y, int32_t Z)
	{
		return (X & Z) | (Y & (~Z));
	}

	static int32_t H(int32_t X, int32_t Y, int32_t Z)
	{
		return X^Y^Z;
	}

	static int32_t I(int32_t X, int32_t Y, int32_t Z)
	{
		return Y ^ (X | (~Z));
	}

	static int32_t RotateLeft(int32_t X, Byte s)
	{
		return ((X << s) | (X >> (32-s)));
	}
	
	static void FF(int32_t& a, int32_t b, int32_t c, int32_t d, int32_t Mj, Byte s, int32_t Ti)
	{
		a = b + RotateLeft(a + F(b, c, d) + Mj + Ti, s); 
	}

	static void GG(int32_t& a, int32_t b, int32_t c, int32_t d, int32_t Mj, Byte s, int32_t Ti)
	{
		a = b + RotateLeft(a + G(b, c, d) + Mj + Ti, s);
	}

	static void HH(int32_t& a, int32_t b, int32_t c, int32_t d, int32_t Mj, Byte s, int32_t Ti)
	{
		a = b + RotateLeft(a + H(b, c, d) + Mj + Ti, s);
	}

	static void II(int32_t& a, int32_t b, int32_t c, int32_t d, int32_t Mj, Byte s, int32_t Ti)
	{
		a = b + RotateLeft(a + I(b, c, d) + Mj + Ti, s);
	}
};
