
#include <stdlib.h>
#include <stdio.h>
#include <UIKit/UIKit.h>

class  CAESCoder
{
public:
	CAESCoder();
	virtual ~CAESCoder();

	int SetCTREncodeContext(uint8_t* pUserKey, int nBits, uint8_t counter[16]);
	uint32_t  EncodeCTR(Byte * pcSrc, uint32_t nLength);

	int			m_nBits;
	uint8_t		m_pcUserKey[32];
	uint8_t		m_OrgCounter[16];
private:
	uint32_t		m_EncKey[64];		/* encryption round keys */
    int			m_nNumOfRounds;		/* number of rounds */
	uint8_t		m_Counter[16];		/* CTR mode counter */
	
	bool		m_bInitial;

	int  aes_set_key(uint8_t *pUserKey, int nBits);
	void aes_encrypt(uint8_t input[16], uint8_t output[16]);
};
