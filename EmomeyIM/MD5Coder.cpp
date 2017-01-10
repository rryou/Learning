// MD5Coder.cpp: implementation of the CMD5Coder class.
//
//////////////////////////////////////////////////////////////////////
#include "MD5Coder.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
/*
const DWORD A = 0x01234567;
const DWORD B = 0x89abcdef;
const DWORD C = 0xfedcba98;
const DWORD D = 0x76543210;
*/

const int32_t A = 0x67452301;
const int32_t B = 0xefcdab89;
const int32_t C = 0x98badcfe;
const int32_t D = 0x10325476;

const unsigned int T[64]= {0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
					0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
					0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
					0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
					0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
					0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
					0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
					0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
					0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
					0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
					0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
					0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
					0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
					0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
					0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
					0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};

const Byte MD5_s[4][4] = {7, 12, 17, 22,
						  5, 9, 14, 20,
						  4, 11, 16, 23,
						  6, 10, 15, 21};

void CMD5Coder::EncodeMD5Raw(Byte* pcValue, int32_t dwLength, char pcHash[16])
{
	int32_t AA, BB, CC, DD;
	int32_t A1, B1, C1, D1;

	int32_t dwRead = 0;
	int32_t dwBlock;
	Byte  acBlock[64];
	int32_t M[16];

	int32_t dwNewLength = (dwLength+8+63)/64*64;
	BOOL  bFillOne = FALSE;
	int32_t dwPos;

	A1 = A;
	B1 = B;
	C1 = C;
	D1 = D;

	while(dwRead < dwNewLength)
	{
		if(dwLength >= 64 + dwRead)
			memcpy(acBlock, pcValue+dwRead, 64);
		else
		{
            memset(acBlock, 0, 64);
//			ZeroMemory(acBlock, 64);
			dwPos = 0;

			if(dwLength > dwRead)
			{
				dwBlock = dwLength - dwRead;

				memcpy(acBlock, pcValue+dwRead, dwBlock);
				dwPos = dwBlock;
			}

			if(!bFillOne)
			{
				acBlock[dwPos] = 128;
				bFillOne = TRUE;
			}
		}
		dwRead += 64;

		if(dwRead == dwNewLength)
		{
			*(int32_t *)(acBlock+56) = dwLength << 3;
			*(int32_t *)(acBlock+60) = dwLength >> 29;
		}

		dwPos = 0;
		for(int i = 0; i < 16; i++)
		{
			M[i] = *((int32_t *)(acBlock+dwPos));
			dwPos += 4;
		}

		AA = A1;
		BB = B1;
		CC = C1;
		DD = D1;

        FF(A1, B1, C1, D1, M[0], MD5_s[0][0], T[0]);
        FF(D1, A1, B1, C1, M[1], MD5_s[0][1], T[1]);
        FF(C1, D1, A1, B1, M[2], MD5_s[0][2], T[2]);
	    FF(B1, C1, D1, A1, M[3], MD5_s[0][3], T[3]);
	    FF(A1, B1, C1, D1, M[4], MD5_s[0][0], T[4]);
	    FF(D1, A1, B1, C1, M[5], MD5_s[0][1], T[5]);
	    FF(C1, D1, A1, B1, M[6], MD5_s[0][2], T[6]);
	    FF(B1, C1, D1, A1, M[7], MD5_s[0][3], T[7]);
	    FF(A1, B1, C1, D1, M[8], MD5_s[0][0], T[8]);
	    FF(D1, A1, B1, C1, M[9], MD5_s[0][1], T[9]);
	    FF(C1, D1, A1, B1, M[10], MD5_s[0][2], T[10]);
	    FF(B1, C1, D1, A1, M[11], MD5_s[0][3], T[11]);
	    FF(A1, B1, C1, D1, M[12], MD5_s[0][0], T[12]);
	    FF(D1, A1, B1, C1, M[13], MD5_s[0][1], T[13]);
	    FF(C1, D1, A1, B1, M[14], MD5_s[0][2], T[14]);
	    FF(B1, C1, D1, A1, M[15], MD5_s[0][3], T[15]);

        GG(A1, B1, C1, D1, M[1], MD5_s[1][0], T[16]);
        GG(D1, A1, B1, C1, M[6], MD5_s[1][1], T[17]);
        GG(C1, D1, A1, B1, M[11], MD5_s[1][2], T[18]);
	    GG(B1, C1, D1, A1, M[0], MD5_s[1][3], T[19]);
	    GG(A1, B1, C1, D1, M[5], MD5_s[1][0], T[20]);
	    GG(D1, A1, B1, C1, M[10], MD5_s[1][1], T[21]);
	    GG(C1, D1, A1, B1, M[15], MD5_s[1][2], T[22]);
	    GG(B1, C1, D1, A1, M[4], MD5_s[1][3], T[23]);
	    GG(A1, B1, C1, D1, M[9], MD5_s[1][0], T[24]);
	    GG(D1, A1, B1, C1, M[14], MD5_s[1][1], T[25]);
	    GG(C1, D1, A1, B1, M[3], MD5_s[1][2], T[26]);
	    GG(B1, C1, D1, A1, M[8], MD5_s[1][3], T[27]);
	    GG(A1, B1, C1, D1, M[13], MD5_s[1][0], T[28]);
	    GG(D1, A1, B1, C1, M[2], MD5_s[1][1], T[29]);
	    GG(C1, D1, A1, B1, M[7], MD5_s[1][2], T[30]);
	    GG(B1, C1, D1, A1, M[12], MD5_s[1][3], T[31]);

        HH(A1, B1, C1, D1, M[5], MD5_s[2][0], T[32]);
        HH(D1, A1, B1, C1, M[8], MD5_s[2][1], T[33]);
        HH(C1, D1, A1, B1, M[11], MD5_s[2][2], T[34]);
	    HH(B1, C1, D1, A1, M[14], MD5_s[2][3], T[35]);
	    HH(A1, B1, C1, D1, M[1], MD5_s[2][0], T[36]);
	    HH(D1, A1, B1, C1, M[4], MD5_s[2][1], T[37]);
	    HH(C1, D1, A1, B1, M[7], MD5_s[2][2], T[38]);
	    HH(B1, C1, D1, A1, M[10], MD5_s[2][3], T[39]);
	    HH(A1, B1, C1, D1, M[13], MD5_s[2][0], T[40]);
	    HH(D1, A1, B1, C1, M[0], MD5_s[2][1], T[41]);
	    HH(C1, D1, A1, B1, M[3], MD5_s[2][2], T[42]);
	    HH(B1, C1, D1, A1, M[6], MD5_s[2][3], T[43]);
	    HH(A1, B1, C1, D1, M[9], MD5_s[2][0], T[44]);
	    HH(D1, A1, B1, C1, M[12], MD5_s[2][1], T[45]);
	    HH(C1, D1, A1, B1, M[15], MD5_s[2][2], T[46]);
	    HH(B1, C1, D1, A1, M[2], MD5_s[2][3], T[47]);

        II(A1, B1, C1, D1, M[0], MD5_s[3][0], T[48]);
        II(D1, A1, B1, C1, M[7], MD5_s[3][1], T[49]);
        II(C1, D1, A1, B1, M[14], MD5_s[3][2], T[50]);
	    II(B1, C1, D1, A1, M[5], MD5_s[3][3], T[51]);
	    II(A1, B1, C1, D1, M[12], MD5_s[3][0], T[52]);
	    II(D1, A1, B1, C1, M[3], MD5_s[3][1], T[53]);
	    II(C1, D1, A1, B1, M[10], MD5_s[3][2], T[54]);
	    II(B1, C1, D1, A1, M[1], MD5_s[3][3], T[55]);
	    II(A1, B1, C1, D1, M[8], MD5_s[3][0], T[56]);
	    II(D1, A1, B1, C1, M[15], MD5_s[3][1], T[57]);
	    II(C1, D1, A1, B1, M[6], MD5_s[3][2], T[58]);
	    II(B1, C1, D1, A1, M[13], MD5_s[3][3], T[59]);
	    II(A1, B1, C1, D1, M[4], MD5_s[3][0], T[60]);
	    II(D1, A1, B1, C1, M[11], MD5_s[3][1], T[61]);
	    II(C1, D1, A1, B1, M[2], MD5_s[3][2], T[62]);
	    II(B1, C1, D1, A1, M[9], MD5_s[3][3], T[63]);

		A1 = A1 + AA;
		B1 = B1 + BB;
		C1 = C1 + CC;
		D1 = D1 + DD;
	}

	M[0] = A1;
	M[1] = B1;
	M[2] = C1;
	M[3] = D1;

	memcpy(pcHash, M, 16);
}

void CMD5Coder::EncodeMD5(Byte* pcValue, int32_t dwLength, char pcDest[33])
{
	char pcHash[16];
	EncodeMD5Raw(pcValue, dwLength, pcHash);

//	ZeroMemory(pcDest, 33);
    memset(pcDest, 0, 33);
	char* pc = pcDest;
    
//	Byte* pcByte = (Byte*)pcHash;
//	for(int i = 0; i < 16; i++, pc+=2)
//		sprintf_s(pc, 3, "%02x", *pcByte++);
}
