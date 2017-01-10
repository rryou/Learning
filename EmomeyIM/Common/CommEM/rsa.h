#ifndef _RSA_H
#define _RSA_H

#ifndef _STD_TYPES
#define _STD_TYPES

#define uchar   unsigned char
//#define uint    unsigned int
//#define ulong   unsigned long int

#endif

#define ERR_RSA_KEYGEN_FAILED           0x0300
#define ERR_RSA_PUBLIC_FAILED           0x0320
#define ERR_RSA_PRIVATE_FAILED          0x0340
#define ERR_RSA_KEY_CHECK_FAILED        0x0360
#define ERR_RSA_ENCRYPT_FAILED          0x0380
#define ERR_RSA_DECRYPT_FAILED          0x03A0
#define ERR_RSA_SIGN_FAILED             0x03C0
#define ERR_RSA_VERIFY_FAILED           0x03E0

/*
 * PKCS#1 stuff
 */

#define RSA_SIGN            0x01
#define RSA_CRYPT           0x02

#include "mpi.h"
#include <UIKit/UIKit.h>
typedef struct
{
    uint ver;   /* should be 0      */
    uint len;   /* size(N) in chars */
    mpi N;      /* public modulus   */
    mpi E;      /* public exponent  */
    mpi D;      /* private exponent */
    mpi P;      /* 1st prime factor */
    mpi Q;      /* 2nd prime factor */
    mpi DP;     /* D mod (P - 1)    */
    mpi DQ;     /* D mod (Q - 1)    */
    mpi QP;     /* inverse of Q % P */
}
rsa_context;

int rsa_import_key( rsa_context *ctx, uint nbits, uchar* N, uchar* E, uchar* D,
					uchar* P, uchar* Q, uchar* DP, uchar* DQ, uchar* QP );

/*
 * Returns 0 if the private key is valid,
 * or ERR_RSA_KEY_CHECK_FAILED.
 */
int rsa_check_privkey( rsa_context *ctx );


/*
 * Perform an RSA private key operation. This function
 * does not take care of message padding: both ilen an
 * olen must be equal to the modulus size (ctx->len).
 *
 * Returns 0 if successful, or ERR_RSA_PRIVATE_FAILED.
 */
int rsa_private( rsa_context *ctx, uchar *input,  uint ilen,
                                   uchar *output, uint olen );

int rsa_pkcs1_encrypt_private( rsa_context *ctx,
                       uchar *input,  uint ilen,
                       uchar *output, uint olen );

/*
 * Perform a private RSA and remove the PKCS1 v1.5 padding.
 *
 *      ctx     points to an RSA private key
 *      input   buffer holding the encrypted data
 *      ilen    must be the same as the modulus size
 *      output  buffer that will hold the plaintext
 *      olen    size of output buffer, will be updated
 *              to contain the length of the plaintext
 *
 * Returns 0 if successful, or ERR_RSA_DECRYPT_FAILED
 */
int rsa_pkcs1_decrypt_private( rsa_context *ctx,
                       uchar *input,  uint  ilen,
                       uchar *output, uint *olen );


/*
 * Returns 0 if the public key is valid,
 * or ERR_RSA_KEY_CHECK_FAILED.
 */
int rsa_check_pubkey( rsa_context *ctx );


/*
 * Add the PKCS1 v1.5 padding and perform a public RSA.
 *
 *      ctx     points to an RSA public key
 *      input   buffer holding the data to be encrypted
 *      ilen    length of the plaintext; cannot be longer
 *              than the modulus, minus 3+8 for padding
 *      output  buffer that will hold the ciphertext
 *      olen    must be the same as the modulus size
 *              (for example, 128 if RSA-1024 is used)
 *
 * Returns 0 if successful, or ERR_RSA_ENCRYPT_FAILED
 */
int rsa_pkcs1_encrypt_public( rsa_context *ctx,
                       uchar *input,  uint ilen,
                       uchar *output, uint olen );


int rsa_pkcs1_decrypt_public( rsa_context *ctx,
                       uchar *input,  uint  ilen,
                       uchar *output, uint *olen );


void rsa_init(rsa_context *ctx);

/*
 * Free the components of an RSA key.
 */
void rsa_free( rsa_context *ctx );

#endif
