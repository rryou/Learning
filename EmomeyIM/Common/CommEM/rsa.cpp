/*
 *  The RSA PK cryptosystem
 *
 *  Copyright (C) 2006  Christophe Devine
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License, version 2.1 as published by the Free Software Foundation.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *  MA  02110-1301  USA
 */
/*
 *  RSA was designed by Ron Rivest, Adi Shamir and Len Adleman.
 *
 *  http://theory.lcs.mit.edu/~rivest/rsapaper.pdf
 *  http://www.cacr.math.uwaterloo.ca/hac/about/chap8.pdf
 */
//
//#include "stdafx.h"


#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "stock_trade_rsa_encrypt.h"

#include "rsa.h"




Byte N[] = {0x43, 0xE7, 0x68, 0x90, 0x24, 0x7F, 0x99, 0xCA,
    0x50, 0x52, 0x27, 0xA6, 0xCF, 0x16, 0xAC, 0x7D,
    0xFE, 0x5C, 0xDD, 0x8E, 0x33, 0x50, 0x69, 0xFC,
    0xD6, 0xD7, 0xF8, 0xBB, 0x39, 0xAD, 0xEB, 0xBD,
    0x5B, 0x0A, 0x3D, 0x78, 0x3D, 0xD7, 0x36, 0x0E,
    0x7F, 0x66, 0xDD, 0x15, 0xC1, 0x02, 0x25, 0x6F,
    0xCF, 0x42, 0x0C, 0xA8, 0x16, 0xA1, 0x1D, 0x17,
    0xE4, 0x47, 0x84, 0xE0, 0x04, 0x3F, 0xE9, 0x94,
    0xD3, 0x54, 0xDE, 0xB2, 0xD7, 0xEE, 0x31, 0x8B,
    0xF7, 0x68, 0xDA, 0x25, 0xB0, 0x7C, 0x38, 0x76,
    0x57, 0x15, 0x57, 0x3C, 0x27, 0x73, 0x09, 0x7F,
    0x25, 0xBE, 0xE2, 0x7E, 0xAD, 0x71, 0xAE, 0xC6,
    0xA5, 0x9B, 0xB3, 0xC4, 0xCC, 0xBC, 0x74, 0x24,
    0xDC, 0x3E, 0xEE, 0x4C, 0x83, 0x51, 0xD1, 0xE1,
    0x79, 0xA8, 0x74, 0x24, 0xFA, 0xAD, 0x50, 0x68,
    0xBA, 0x70, 0xBC, 0xC4, 0x51, 0xA3, 0xDD, 0xAF};

Byte E[] = {0x01, 0x00, 0x01, 0x00};


int rsa_import_key( rsa_context *ctx, uint nbits, uchar* N, uchar* E, uchar* D,
					uchar* P, uchar* Q, uchar* DP, uchar* DQ, uchar* QP )
{
    int ret;

    memset( ctx, 0, sizeof( rsa_context ) );

    ctx->len = nbits / 8;

	if(N != NULL)
		CHK( mpi_read(&ctx->N, (char*)N, 16) );

	if(E != NULL)
		CHK( mpi_read(&ctx->E, (char*)E, 16) );

	if(D != NULL)
		CHK( mpi_read(&ctx->D, (char*)D, 16) );

	if(P != NULL)
		CHK( mpi_read(&ctx->P, (char*)P, 16) );

	if(Q != NULL)
		CHK( mpi_read(&ctx->Q, (char*)Q, 16) );

	if(DP != NULL)
		CHK( mpi_read(&ctx->DP, (char*)DP, 16) );

	if(DQ != NULL)
		CHK( mpi_read(&ctx->DQ, (char*)DQ, 16) );

	if(QP != NULL)
		CHK( mpi_read(&ctx->QP, (char*)QP, 16) );

cleanup:
	return ret;
}


/*
 * Returns 0 if the private key is valid,
 * or ERR_RSA_KEY_CHECK_FAILED.
 */
int rsa_check_privkey( rsa_context *ctx )
{
    int ret = 0;
    mpi TN, P1, Q1, H, G;

    mpi_init( &TN, &P1, &Q1, &H, &G, NULL );

    CHK( mpi_mul_mpi( &TN, &ctx->P, &ctx->Q ) );
    CHK( mpi_sub_int( &P1, &ctx->P, 1 ) );
    CHK( mpi_sub_int( &Q1, &ctx->Q, 1 ) );
    CHK( mpi_mul_mpi( &H, &P1, &Q1 ) );
    CHK( mpi_gcd( &G, &ctx->E, &H  ) );

    if( mpi_cmp_mpi( &TN, &ctx->N ) == 0 &&
        mpi_cmp_int( &G, 1 ) == 0 )
    {
        mpi_free( &TN, &P1, &Q1, &H, &G, NULL );
        return( 0 );
    }

cleanup:

    mpi_free( &TN, &P1, &Q1, &H, &G, NULL );
    return( ERR_RSA_KEY_CHECK_FAILED | ret );
}


/*
 * Perform an RSA private key operation. This function
 * does not take care of message padding: both ilen an
 * olen must be equal to the modulus size (ctx->len).
 *
 * Returns 0 if successful, or ERR_RSA_PRIVATE_FAILED.
 */
int rsa_private( rsa_context *ctx, uchar *input,  uint ilen,
                                   uchar *output, uint olen )
{
    int ret;
    mpi T, T1, T2;

    if( ilen != ctx->len || olen != ctx->len )
        return( ERR_RSA_PRIVATE_FAILED );

    mpi_init( &T, &T1, &T2, NULL );

    CHK( mpi_import( &T, input, ilen ) );

    if( mpi_cmp_mpi( &T, &ctx->N ) >= 0 )
    {
        mpi_free( &T, NULL );
        return( ERR_RSA_PRIVATE_FAILED );
    }

#if 0
    CHK( mpi_exp_mod( &T, &T, &ctx->D, &ctx->N ) );
#else
    /*
     * faster decryption using the CRT
     *
     * T1 = input ^ dP mod P
     * T2 = input ^ dQ mod Q
     */
    CHK( mpi_exp_mod( &T1, &T, &ctx->DP, &ctx->P ) );
    CHK( mpi_exp_mod( &T2, &T, &ctx->DQ, &ctx->Q ) );

    /*
     * T = (T1 - T2) * (Q^-1 mod P) mod P
     */
    CHK( mpi_sub_mpi( &T, &T1, &T2 ) );
    CHK( mpi_mul_mpi( &T1, &T, &ctx->QP ) );
    CHK( mpi_mod_mpi( &T, &T1, &ctx->P ) );

    /*
     * output = T2 + T * Q
     */
    CHK( mpi_mul_mpi( &T1, &T, &ctx->Q ) );
    CHK( mpi_add_mpi( &T, &T2, &T1 ) );

#endif

    CHK( mpi_export( &T, output, &olen ) );

cleanup:

    mpi_free( &T, &T1, &T2, NULL );

    if( ret != 0 )
        return( ERR_RSA_PRIVATE_FAILED | ret );

    return( 0 );
}


int rsa_pkcs1_encrypt_private( rsa_context *ctx,
                       uchar *input,  uint ilen,
                       uchar *output, uint olen )
{
	int nb_pad;
	uchar *p = output;

	if( olen != ctx->len || olen < ilen + 11 )
		return( ERR_RSA_ENCRYPT_FAILED );

	nb_pad = olen - 3 - ilen;

	*p++ = 0;
	*p++ = RSA_SIGN;

    memset( p, 0xFF, nb_pad );
    p += nb_pad;
    *p++ = 0;

	memcpy( p, input, ilen );

    if( rsa_private( ctx, output, olen, output, olen ) != 0 )
        return( ERR_RSA_SIGN_FAILED );

    return( 0 );
}


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
                       uchar *output, uint *olen )
{
    uchar *p, tmp[512];

    if( ilen != ctx->len || ilen < 48 || ilen > 512 )
        return( ERR_RSA_DECRYPT_FAILED );

    if( rsa_private( ctx, input, ilen, tmp, ilen ) != 0 )
        return( ERR_RSA_DECRYPT_FAILED );

    p = tmp;

    if( *p++ != 0 || *p++ != RSA_CRYPT )
        return( ERR_RSA_DECRYPT_FAILED );

    while( *p != 0 )
    {
        if( p >= tmp + ilen - 1 )
            return( ERR_RSA_DECRYPT_FAILED );
        p++;
    }
    p++;

    if( *olen < ilen - (uint)(p - tmp) )
        return( ERR_RSA_DECRYPT_FAILED );

    *olen = ilen - (uint)(p - tmp);
    memcpy( output, p, *olen );

    return( 0 );
}

/*
 * Returns 0 if the public key is valid,
 * or ERR_RSA_KEY_CHECK_FAILED.
 */
int rsa_check_pubkey( rsa_context *ctx )
{
    if( ( ctx->N.p[0] & 1 ) == 0 || 
        ( ctx->E.p[0] & 1 ) == 0 )
        return( ERR_RSA_KEY_CHECK_FAILED );

    if( mpi_size( &ctx->N ) < 128 ||
        mpi_size( &ctx->N ) > 4096 )
        return( ERR_RSA_KEY_CHECK_FAILED );

    if( mpi_size( &ctx->E ) < 2 ||
        mpi_size( &ctx->E ) > 64 )
        return( ERR_RSA_KEY_CHECK_FAILED );

    return( 0 );
}


/*
 * Perform an RSA public key operation. This function
 * does not take care of message padding: both ilen and
 * olen must be equal to the modulus size (ctx->len).
 *
 * Returns 0 if successful, or ERR_RSA_PUBLIC_FAILED.
 */
int rsa_public( rsa_context *ctx, uchar *input,  uint ilen,
                                  uchar *output, uint olen )
{
    int ret;
    mpi T;

    if( ilen != ctx->len || olen != ctx->len )
        return( ERR_RSA_PUBLIC_FAILED );

    mpi_init( &T, NULL );

    CHK( mpi_import( &T, input, ilen ) );

    if( mpi_cmp_mpi( &T, &ctx->N ) >= 0 )
    {
        mpi_free( &T, NULL );
        return( ERR_RSA_PUBLIC_FAILED );
    }

    CHK( mpi_exp_mod( &T, &T, &ctx->E, &ctx->N ) );
    CHK( mpi_export( &T, output, &olen ) );

cleanup:

    mpi_free( &T, NULL );

    if( ret != 0 )
        return( ERR_RSA_PUBLIC_FAILED | ret );

    return( 0 );
}
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
//新增的RSA加密方法，尤荣荣

int RsaEncode(Byte *pc_data, uint lenth,uchar *output,uint *olen){
    Byte changeN[128];
    Byte changeE[4] = { 0x00, 0x01, 0x00, 0x01};
    for (NSInteger i = 127; i >=0; i --) {
        changeN[127 - i] = N[i];
    }
    char *resultdata = RSA_Encrypt(pc_data, lenth, changeN, 128, changeE, 4);
    uint length = (uint)strlen(resultdata);
    *olen = length/2;
    uchar *encodeStr= preCode((uchar *)resultdata, (int) length);
    memcpy(output, encodeStr, length/2);
    return 0;
}

//

int rsa_pkcs1_encrypt_public( rsa_context *ctx,
                       uchar *input,  uint ilen,
                       uchar *output, uint olen ){
    int nb_pad;
    uchar *p = output;
//注册的原因是不采用rsa_context进行加密，因此判断无效
//    if( olen != ctx->len || olen < ilen + 11 )
//        return( ERR_RSA_ENCRYPT_FAILED );

    nb_pad = olen - 3 - ilen;

    *p++ = 0;
    *p++ = RSA_CRYPT;

    while( nb_pad-- > 0 )
    {
//       *p = 0;
         do { *p = (uchar)rand(); } while( *p == 0 );
        p++;
    }

    *p++ = 0;
    memcpy( p, input, ilen );

//    if( rsa_public( ctx, output, olen, output, olen) != 0 )
//        return( ERR_RSA_ENCRYPT_FAILED );
//新增的rsa方法
    if (RsaEncode(output,olen,output ,&olen) != 0) {
        return( ERR_RSA_DECRYPT_FAILED );
    }
//    for (int i = 0; i < olen; i++) {
  //      NSLog([NSString stringWithFormat:@"out:%d  i: %d ",(char)output[i],i]);
  //  }
    
    return( 0 );
}

int rsa_pkcs1_decrypt_public( rsa_context *ctx,
                       uchar *input,  uint ilen,
                       uchar *output, uint *olen )
{
    uchar *p, tmp[512];
//注册的原因是不采用rsa_context进行加密，因此判断无效
    
//    if( ilen != ctx->len || ilen < 48 || ilen > 512 )
//        return( ERR_RSA_DECRYPT_FAILED );

//    if( rsa_public( ctx, input, ilen, tmp, ilen ) != 0 )
//        return( ERR_RSA_DECRYPT_FAILED );
//新增加密的方式
//    for (int i = 0; i < ilen; i++) {
//        NSLog([NSString stringWithFormat:@"out:%d  i: %d ",(char)input[i],i]);
//    }

    if (RsaEncode(input,ilen,tmp ,&ilen) != 0) {
       return( ERR_RSA_DECRYPT_FAILED );
    }
    p = tmp;

//代码注册的原因是因为这个RSA加密算法有缺陷，128btye进入加密后只有127byte，头部的0被忽然
    
//    if( *p++ != 0 || *p++ != RSA_SIGN )
//        return( ERR_RSA_DECRYPT_FAILED );

    while( *p != 0 )
    {
        if( p >= tmp + ilen - 1 )
            return( ERR_RSA_DECRYPT_FAILED );
        p++;
    }
    p++;

    if( *olen < ilen - (uint)(p - tmp) )
        return( ERR_RSA_DECRYPT_FAILED );

    *olen = ilen - (uint)(p - tmp);
    memcpy( output, p, *olen );

    return( 0 );
}


void rsa_init(rsa_context *ctx)
{
	memset( ctx, 0, sizeof( rsa_context ) );
}

/*
 * Free the components of an RSA key.
 */
void rsa_free( rsa_context *ctx )
{
    mpi_free( &ctx->N,  &ctx->E,  &ctx->D,
              &ctx->P,  &ctx->Q,  &ctx->DP,
              &ctx->DQ, &ctx->QP, NULL );
}
