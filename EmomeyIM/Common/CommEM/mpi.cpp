/*
 *  Multi-precision integer library
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
 *  This MPI implementation is based on:
 *
 *  http://www.cacr.math.uwaterloo.ca/hac/about/chap14.pdf
 *  http://math.libtomcrypt.com/files/tommath.pdf
 */

//#include "stdafx.h"

#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

#include "mpi.h"

#define ciL    sizeof(t_int)    /* chars in limb  */
#define biL    (ciL << 3)       /* bits  in limb  */
#define biH    (ciL << 2)       /* half limb size */

/*  
 * Bits/chars to # of limbs conversion
 */
#define BITS_TO_LIMBS(i)  (((i) + biL - 1) / biL)
#define CHARS_TO_LIMBS(i) (((i) + ciL - 1) / ciL)

/*
 * Initialize one or more mpi
 */
void mpi_init( mpi *X, ... )
{
    va_list args;

    va_start( args, X );

    while( X != NULL )
    {
        memset( X, 0, sizeof( mpi ) );
        X = va_arg( args, mpi* );
    }

    va_end( args );
}

/*
 * Unallocate one or more mpi
 */
void mpi_free( mpi *X, ... )
{
    va_list args;

    va_start( args, X );

    while( X != NULL )
    {
        if( X->p != NULL )
        {
            memset( X->p, 0, X->n * ciL );
            free( X->p );
        }

        X = va_arg( args, mpi* );
    }

    va_end( args );
}

/*
 * Enlarge total size to the specified # of limbs
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_grow( mpi *X, int nblimbs )
{
    int n = X->n;

    if( n < nblimbs )
    {
        if( X->s == 0 )
            X->s = 1;

        X->n = nblimbs;
        X->p = (t_int *) realloc( X->p, X->n * ciL );

        if( X->p == NULL )
            return( 1 );

        memset( X->p + n, 0, ( X->n - n ) * ciL );
    }

    return( 0 );
}

/*
 * Set value to integer z
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_lset( mpi *X, int z )
{
    int ret;

    CHK( mpi_grow( X, 1 ) );
    memset( X->p, 0, X->n * ciL );
    X->p[0] = ( z < 0 ) ? -z : z;
    X->s    = ( z < 0 ) ? -1 : 1;

cleanup:

    return( ret );
}

/*
 * Copy the contents of Y into X
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_copy( mpi *X, mpi *Y )
{
    int ret, i;

    if( X == Y )
        return( 0 );

    for( i = Y->n - 1; i > 0; i-- )
        if( Y->p[i] != 0 )
            break;
    i++;

    X->s = Y->s;

    CHK( mpi_grow( X, i ) );

    memset( X->p, 0, X->n * ciL );
    memcpy( X->p, Y->p, i * ciL );

cleanup:

    return( ret );
}
/* 
 * Convert an ASCII character to digit value
 *
 * Returns 0 if successful
 *         ERR_MPI_INVALID_CHARACTER if conversion to digit failed
 */
int mpi_get_digit( t_int *d, int radix, char c )
{
    *d = 16;

    if( c >= 0x30 && c <= 0x39 ) *d = c - 0x30;
    if( c >= 0x41 && c <= 0x46 ) *d = c - 0x37;
    if( c >= 0x61 && c <= 0x66 ) *d = c - 0x57;

    if( *d >= (t_int) radix )
        return( ERR_MPI_INVALID_CHARACTER );

    return( 0 );
}

/*
 * Set value from string
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_INVALID_PARAMETER if radix is not between 2 and 16
 *         ERR_MPI_INVALID_CHARACTER if a non-digit character is found
 */
int mpi_read( mpi *X, char *s, int radix )
{
    int ret, i, j, n;
    t_int d;
    mpi T;

    if( radix < 2 || radix > 16 )
        return( ERR_MPI_INVALID_PARAMETER );

    mpi_init( &T, NULL );

    if( radix == 16 )
    {
        n = BITS_TO_LIMBS( int(strlen(s)) << 2 );

        CHK( mpi_grow( X, n ) );
        CHK( mpi_lset( X, 0 ) );

        for( i = int(strlen(s)) - 1, j = 0; i >= 0; i--, j++ )
        {
            if( i == 0 && s[i] == '-' )
            {
                X->s = -1;
                break;
            }

            CHK( mpi_get_digit( &d, radix, s[i] ) );
            X->p[j / (ciL * 2)] |= d << ( (j % (ciL * 2)) << 2 );
        }
    }
    else
    {
        CHK( mpi_lset( X, 0 ) );

        for( i = 0; i < (int) strlen( s ); i++ )
        {
            if( i == 0 && s[i] == '-' )
            {
                X->s = -1;
                continue;
            }

            CHK( mpi_get_digit( &d, radix, s[i] ) );
            CHK( mpi_mul_int( &T, X, radix ) );
            CHK( mpi_add_int( X, &T, d ) );
        }
    }

cleanup:

    mpi_free( &T, NULL );
    return( ret );
}

int mpi_read_bytes( mpi *X, char *pcSrc, int nBytes )
{
	int ret = 0;
	int nMoreBytes = 0;
	char* pcMpi = NULL;

	int n = CHARS_TO_LIMBS(nBytes);

    CHK( mpi_grow( X, n ) );
    CHK( mpi_lset( X, 0 ) );

	pcMpi = (char*)X->p;

	nMoreBytes = n*ciL - nBytes;
	if(nMoreBytes > 0)
	{
		memset(pcMpi, 0, nMoreBytes);
		pcMpi += nMoreBytes;
	}

	memcpy(pcMpi, pcSrc, nBytes);

cleanup:
	return ret;
}

/*
 * Import unsigned value from binary data
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_import( mpi *X, unsigned char *buf, uint buflen )
{
    int ret, i, j;
    uint n;

    for( n = 0; n < buflen; n++ )
        if( buf[n] != 0 )
            break;

    CHK( mpi_grow( X, CHARS_TO_LIMBS(buflen - n) ) );
    CHK( mpi_lset( X, 0 ) );

    for( i = buflen - 1, j = 0; i >= (int) n; i--, j++ )
        X->p[j / ciL] |= (t_int) buf[i] << ((j % ciL ) << 3);

cleanup:

    return( ret );
}

/*
 * Export unsigned value into binary data
 *
 * Call this function with buflen = 0 to obtain the required
 * buffer size in buflen.
 *
 * Returns 0 if successful
 *         ERR_MPI_BUFFER_TOO_SMALL if buf hasn't enough room
 */
int mpi_export( mpi *X, unsigned char *buf, uint *buflen )
{
    int i, j;
    uint n;

    n = ( mpi_size( X ) + 7 ) >> 3;

    if( *buflen < n )
    {
        *buflen = n;
        return( ERR_MPI_BUFFER_TOO_SMALL );
    }

    memset( buf, 0, *buflen );

    for( i = *buflen - 1, j = 0; n > 0; i--, j++, n-- )
        buf[i] = (uchar) (X->p[j / ciL] >> ((j % ciL) << 3));

    return( 0 );
}

/*
 * Returns actual size in bits
 */
uint mpi_size( mpi *X )
{
    int i, j;

    for( i = X->n - 1; i > 0; i-- )
        if( X->p[i] != 0 )
            break;

    for( j = biL - 1; j >= 0; j-- )
        if( ( ( X->p[i] >> j ) & 1 ) != 0 )
            break;

    return( ( i * biL ) + j + 1 );
}

/*
 * Returns # of least significant bits
 */
uint mpi_lsb( mpi *X )
{
    int i, j;
    uint count = 0;

    for( i = 0; i < X->n; i++ )
        for( j = 0; j < (int) biL; j++, count++ )
            if( ( ( X->p[i] >> j ) & 1 ) != 0 )
                return( count );

    return( 0 );
}

/*
 * Left-shift: X <<= count
 *
 * Returns 0 if successful,
 *         1 if memory allocation failed
 */
int mpi_shift_l( mpi *X, uint count )
{
    int ret, i, v0, t1;
    t_int r0 = 0, r1;

    v0 = count /  biL;
    t1 = count & (biL - 1);

    i = mpi_size( X ) + count;

    if( X->n * (int) biL < i )
        CHK( mpi_grow( X, BITS_TO_LIMBS( i ) ) );

    ret = 0;

    /*
     * shift by count / limb_size
     */
    if( v0 > 0 )
    {
        for( i = X->n - 1; i >= v0; i-- )
            X->p[i] = X->p[i - v0];

        for( ; i >= 0; i-- )
            X->p[i] = 0;
    }

    /*
     * shift by count % limb_size
     */
    if( t1 > 0 )
    {
        for( i = v0; i < X->n; i++ )
        {
            r1 = X->p[i] >> (biL - t1);
            X->p[i] <<= t1;
            X->p[i] |= r0;
            r0 = r1;
        }
    }

cleanup:

    return( ret );
}

/*
 * Right-shift: X >>= count
 *
 * Always returns 0.
 */
int mpi_shift_r( mpi *X, uint count )
{
    int i, v0, v1;
    t_int r0 = 0, r1;

    v0 = count /  biL;
    v1 = count & (biL - 1);

    /*
     * shift by count / limb_size
     */
    if( v0 > 0 )
    {
        for( i = 0; i < X->n - v0; i++ )
            X->p[i] = X->p[i + v0];

        for( ; i < X->n; i++ )
            X->p[i] = 0;
    }

    /*
     * shift by count % limb_size
     */
    if( v1 > 0 )
    {
        for( i = X->n - 1; i >= 0; i-- )
        {
            r1 = X->p[i] << (biL - v1);
            X->p[i] >>= v1;
            X->p[i] |= r0;
            r0 = r1;
        }
    }

    return( 0 );
}

/*
 * Compare absolute values
 *
 * Returns 1 if |X| is greater than |Y|
 *        -1 if |X| is lesser  than |Y|
 *         0 if |X| is equal to |Y|
 */
int mpi_cmp_abs( mpi *X, mpi *Y )
{
    int i, j;

    for( i = X->n - 1; i >= 0; i-- )
        if( X->p[i] != 0 )
            break;

    for( j = Y->n - 1; j >= 0; j-- )
        if( Y->p[j] != 0 )
            break;

    if( i < 0 && j < 0 )
        return( 0 );

    if( i > j ) return(  1 );
    if( j > i ) return( -1 );

    for( ; i >= 0; i-- )
    {
        if( X->p[i] > Y->p[i] ) return(  1 );
        if( X->p[i] < Y->p[i] ) return( -1 );
    }

    return( 0 );
}

/*
 * Compare signed values
 *
 * Returns 1 if X is greater than Y
 *        -1 if X is lesser  than Y
 *         0 if X is equal to Y
 */
int mpi_cmp_mpi( mpi *X, mpi *Y )
{
    int i, j;

    for( i = X->n - 1; i >= 0; i-- )
        if( X->p[i] != 0 )
            break;

    for( j = Y->n - 1; j >= 0; j-- )
        if( Y->p[j] != 0 )
            break;

    if( i < 0 && j < 0 )
        return( 0 );

/*
    if( i > j ) return(  X->s );
    if( j > i ) return( -X->s );

    if( X->s > 0 && Y->s < 0 ) return(  1 );
    if( Y->s > 0 && X->s < 0 ) return( -1 );	
*/

    if( X->s > 0 && Y->s < 0 ) return(  1 );
    if( Y->s > 0 && X->s < 0 ) return( -1 );

    if( i > j ) return(  X->s );
    if( j > i ) return( -X->s );

    for( ; i >= 0; i-- )
    {
        if( X->p[i] > Y->p[i] ) return(  X->s );
        if( X->p[i] < Y->p[i] ) return( -X->s );
    }

    return( 0 );
}

/*
 * Compare signed values
 *
 * Returns 1 if X is greater than z
 *        -1 if X is lesser  than z
 *         0 if X is equal to z
 */
int mpi_cmp_int( mpi *X, int z )
{
    mpi Y;
    t_int p[1];

    *p  = ( z < 0 ) ? -z : z;
    Y.s = ( z < 0 ) ? -1 : 1;
    Y.n = 1;
    Y.p = p;

    return( mpi_cmp_mpi( X, &Y ) );
}

/*
 * Unsigned addition: X = |A| + |B|  (HAC 14.7)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_add_abs( mpi *X, mpi *A, mpi *B )
{
    int ret, i, j;
    t_int *o, *p, c;

    if( X == B )
    {
        mpi *T = A; A = X; B = T;
    }

    if( X != A )
        CHK( mpi_copy( X, A ) );

    for( j = B->n - 1; j >= 0; j-- )
        if( B->p[j] != 0 )
            break;

    CHK( mpi_grow( X, j + 1 ) );

    o = B->p; p = X->p; c = 0;

    for( i = 0; i <= j; i++, o++, p++ )
    {
        *p +=  c; c  = ( *p <  c );
        *p += *o; c += ( *p < *o );
    }

    while( c != 0 )
    {
        if( i >= X->n )
        {
            CHK( mpi_grow( X, i + 1 ) );
            p = X->p + i;
        }

        *p += c; c = ( *p < c ); i++;
    }

cleanup:

    return( ret );
}

/*
 * Unsigned substraction: X = |A| - |B|  (HAC 14.9)
 *
 * Returns 0 if successful
 *         ERR_MPI_NEGATIVE_VALUE if B is greater than A
 */
int mpi_sub_abs( mpi *X, mpi *A, mpi *B )
{
    mpi TB;
    int ret, i, j;
    t_int *o, *p, c, z;

    if( mpi_cmp_abs( A, B ) < 0 )
        return( ERR_MPI_NEGATIVE_VALUE );

    mpi_init( &TB, NULL );

    if( X == B )
    {
        CHK( mpi_copy( &TB, B ) );
        B = &TB;
    }

    if( X != A )
        CHK( mpi_copy( X, A ) );

    ret = 0;

    for( j = B->n - 1; j >= 0; j-- )
        if( B->p[j] != 0 )
            break;

    o = B->p; p = X->p; c = 0;

    for( i = 0; i <= j; i++, o++, p++ )
    {
        z = ( *p <  c );     *p -=  c;
        c = ( *p < *o ) + z; *p -= *o;
    }

    while( c != 0 )
    {
        z = ( *p < c ); *p -= c;
        c = z; i++; p++;
    }

cleanup:

    mpi_free( &TB, NULL );
    return( ret );
}

/*
 * Signed addition: X = A + B
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_add_mpi( mpi *X, mpi *A, mpi *B )
{
    int ret, s = A->s;

    if( A->s * B->s < 0 )
    {
        if( mpi_cmp_abs( A, B ) >= 0 )
        {
            CHK( mpi_sub_abs( X, A, B ) );
            X->s =  s;
        }
        else
        {
            CHK( mpi_sub_abs( X, B, A ) );
            X->s = -s;
        }
    }
    else
    {
        CHK( mpi_add_abs( X, A, B ) );
        X->s = s;
    }

cleanup:

    return( ret );
}

/*
 * Signed substraction: X = A - B
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_sub_mpi( mpi *X, mpi *A, mpi *B )
{
    int ret, s = A->s;

    if( A->s * B->s > 0 )
    {
        if( mpi_cmp_abs( A, B ) >= 0 )
        {
            CHK( mpi_sub_abs( X, A, B ) );
            X->s =  s;
        }
        else
        {
            CHK( mpi_sub_abs( X, B, A ) );
            X->s = -s;
        }
    }
    else
    {
        CHK( mpi_add_abs( X, A, B ) );
        X->s = s;
    }

cleanup:

    return( ret );
}

/*
 * Signed addition: X = A + b
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_add_int( mpi *X, mpi *A, int b )
{
    mpi _B;
    t_int p[1];

    p[0] = ( b < 0 ) ? -b : b;
    _B.s = ( b < 0 ) ? -1 : 1;
    _B.n = 1;
    _B.p = p;

    return( mpi_add_mpi( X, A, &_B ) );
}

/*
 * Signed substraction: X = A - b
 *
 * Returns 0 if successful,
 *         1 if memory allocation failed
 */
int mpi_sub_int( mpi *X, mpi *A, int b )
{
    mpi _B;
    t_int p[1];

    p[0] = ( b < 0 ) ? -b : b;
    _B.s = ( b < 0 ) ? -1 : 1;
    _B.n = 1;
    _B.p = p;

    return( mpi_sub_mpi( X, A, &_B ) );
}

/* 
 * Multiply source s with b, add result to
 * destination d and set carry c.
 */
#if defined _MSC_VER_TEST_

#define MULADDC_INIT                    \
    __asm   mov     esi, s              \
    __asm   mov     edi, d              \
    __asm   mov     ecx, c              \
    __asm   mov     ebx, b

#define MULADDC_CORE                    \
    __asm   lodsd                       \
    __asm   mul     ebx                 \
    __asm   add     eax, ecx            \
    __asm   adc     edx, 0              \
    __asm   add     eax, [edi]          \
    __asm   adc     edx, 0              \
    __asm   mov     ecx, edx            \
    __asm   stosd

#define MULADDC_STOP                    \
    __asm   mov     c, ecx              \
    __asm   mov     d, edi              \
    __asm   mov     s, esi              \

#else
#if defined __i386__

#define MULADDC_INIT                    \
    asm( "movl  %0, %%esi" :: "m" (s)); \
    asm( "movl  %0, %%edi" :: "m" (d)); \
    asm( "movl  %0, %%ecx" :: "m" (c)); \
    asm( "movl  %0, %%ebx" :: "m" (b));

#define MULADDC_CORE                    \
    asm( "lodsl                 " );    \
    asm( "mull  %ebx            " );    \
    asm( "addl  %ecx,   %eax    " );    \
    asm( "adcl  $0,     %edx    " );    \
    asm( "addl  (%edi), %eax    " );    \
    asm( "adcl  $0,     %edx    " );    \
    asm( "movl  %edx,   %ecx    " );    \
    asm( "stosl                 " );

#define MULADDC_STOP                    \
    asm( "movl  %%ecx, %0" :: "m" (c)); \
    asm( "movl  %%edi, %0" :: "m" (d)); \
    asm( "movl  %%esi, %0" :: "m" (s) : \
         "eax", "ecx", "edx",           \
         "ebx", "esi", "edi" );

#else
#if defined __amd64__

#define MULADDC_INIT                    \
    asm( "movq  %0, %%rsi" :: "m" (s)); \
    asm( "movq  %0, %%rdi" :: "m" (d)); \
    asm( "movq  %0, %%rcx" :: "m" (c)); \
    asm( "movq  %0, %%rbx" :: "m" (b));

#define MULADDC_CORE                    \
    asm( "lodsq                 " );    \
    asm( "mulq  %rbx            " );    \
    asm( "addq  %rcx,   %rax    " );    \
    asm( "adcq  $0,     %rdx    " );    \
    asm( "addq  (%rdi), %rax    " );    \
    asm( "adcq  $0,     %rdx    " );    \
    asm( "movq  %rdx,   %rcx    " );    \
    asm( "stosq                 " );

#define MULADDC_STOP                    \
    asm( "movq  %%rcx, %0" :: "m" (c)); \
    asm( "movq  %%rdi, %0" :: "m" (d)); \
    asm( "movq  %%rsi, %0" :: "m" (s) : \
         "rax", "rcx", "rdx",           \
         "rbx", "rsi", "rdi" );

#else

//#warning : no muladdc assembly code for this cpu

#define MULADDC_INIT                    \
{                                       \
    t_int s0, s1, b0, b1;               \
    t_int r0, r1, rx, ry;               \
    b0 = ( b << biH ) >> biH;           \
    b1 = ( b >> biH );

#define MULADDC_CORE                    \
    s0 = ( *s << biH ) >> biH;          \
    s1 = ( *s >> biH ); s++;            \
    rx = s0 * b1; r0 = s0 * b0;         \
    ry = s1 * b0; r1 = s1 * b1;         \
    r1 += ( rx >> biH );                \
    r1 += ( ry >> biH );                \
    rx <<= biH; ry <<= biH;             \
    r0 += rx; r1 += (r0 < rx);          \
    r0 += ry; r1 += (r0 < ry);          \
    r0 +=  c; r1 += (r0 <  c);          \
    r0 += *d; r1 += (r0 < *d);          \
    c = r1; *(d++) = r0;

#define MULADDC_STOP                    \
}

#endif
#endif
#endif

void MULADDC( int i, t_int *s, t_int *d, t_int b )
{
    t_int c = 0;

    for( ; i >= 16; i -= 16 )
    {
        MULADDC_INIT
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_STOP
    }

    for( ; i >= 4; i -= 4 )
    {
        MULADDC_INIT
        MULADDC_CORE  MULADDC_CORE
        MULADDC_CORE  MULADDC_CORE
        MULADDC_STOP
    }

    for( ; i > 0; i-- )
    {
        MULADDC_INIT
        MULADDC_CORE
        MULADDC_STOP
    }

    do {
        *d += c; c = ( *d < c ); d++;
    }
    while( c != 0 );
}

/*
 * Baseline multiplication: X = A * B  (HAC 14.12)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_mul_mpi( mpi *X, mpi *A, mpi *B )
{
    int ret, i, j;
    mpi TA, TB;

    mpi_init( &TA, &TB, NULL );

    if( X == A ) { CHK( mpi_copy( &TA, A ) ); A = &TA; }
    if( X == B ) { CHK( mpi_copy( &TB, B ) ); B = &TB; }

    for( i = A->n - 1; i >= 0; i-- )
        if( A->p[i] != 0 )
            break;

    for( j = B->n - 1; j >= 0; j-- )
        if( B->p[j] != 0 )
            break;

    CHK( mpi_grow( X, i + j + 2 ) );
    CHK( mpi_lset( X, 0 ) );

    for( i++; j >= 0; j-- )
        MULADDC( i, A->p, X->p + j, B->p[j] );

    X->s = A->s * B->s;

cleanup:

    mpi_free( &TB, &TA, NULL );
    return( ret );
}

/*
 * Baseline multiplication: X = A * b
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_mul_int( mpi *X, mpi *A, t_int b )
{
    mpi _B;
    t_int p[1];

    _B.s = 1;
    _B.n = 1;
    _B.p = p;
    p[0] = b;

    return( mpi_mul_mpi( X, A, &_B ) );
}

/*
 * Division by mpi: A = Q * B + R  (HAC 14.20)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_DIVISION_BY_ZERO if B == 0
 */
int mpi_div_mpi( mpi *Q, mpi *R, mpi *A, mpi *B )
{
    int ret, i, n, t, k;
    mpi X, Y, Z, T1, T2;
    t_int q0, q1, r0, r1;
    t_int d0, d1, d, m;

    if( mpi_cmp_int( B, 0 ) == 0 )
        return( ERR_MPI_DIVISION_BY_ZERO );

    mpi_init( &X, &Y, &Z, &T1, &T2, NULL );

    if( mpi_cmp_abs( A, B ) < 0 )
    {
        if( Q != NULL ) CHK( mpi_lset( Q, 0 ) );
        if( R != NULL ) CHK( mpi_copy( R, A ) );
        return( 0 );
    }

    CHK( mpi_copy( &X, A ) );
    CHK( mpi_copy( &Y, B ) );
    X.s = Y.s = 1;

    CHK( mpi_grow( &Z, A->n + 2 ) );
    CHK( mpi_lset( &Z,  0 ) );
    CHK( mpi_grow( &T1, 2 ) );
    CHK( mpi_grow( &T2, 3 ) );

    k = mpi_size( &Y ) % biL;
    if( k < (int) biL - 1 )
    {
        k = biL - 1 - k;
        CHK( mpi_shift_l( &X, k ) );
        CHK( mpi_shift_l( &Y, k ) );
    }
    else k = 0;

    n = X.n - 1;
    t = Y.n - 1;
    mpi_shift_l( &Y, biL * (n - t) );
    while( mpi_cmp_mpi( &X, &Y ) >= 0 )
    {
        Z.p[n - t]++;
        mpi_sub_mpi( &X, &X, &Y );
    }
    mpi_shift_r( &Y, biL * (n - t) );

    for( i = n; i > t ; i-- )
    {
        if( X.p[i] >= Y.p[t] )
            Z.p[i - t - 1] = ~0;
        else
        {
            /*
             * __udiv_qrnnd_c, from GMP/longlong.h
             */
            d  = Y.p[t];
            d0 = ( d << biH ) >> biH;
            d1 = ( d >> biH );

            q1 = X.p[i] / d1;
            r1 = X.p[i] - d1 * q1;
            r1 <<= biH;
            r1 |= ( X.p[i - 1] >> biH );

            m = q1 * d0;
            if( r1 < m )
            {
                q1--, r1 += d;
                while( r1 >= d && r1 < m )
                    q1--, r1 += d;
            }
            r1 -= m;
            
            q0 = r1 / d1;
            r0 = r1 - d1 * q0;
            r0 <<= biH;
            r0 |= ( X.p[i - 1] << biH ) >> biH;

            m = q0 * d0;
            if( r0 < m )
            {
                q0--, r0 += d;
                while( r0 >= d && r0 < m )
                    q0--, r0 += d;
            }
            r0 -= m;

            Z.p[i - t - 1] = ( q1 << biH ) | q0;
        }

        Z.p[i - t - 1]++;
        do
        {
            Z.p[i - t - 1]--;

            CHK( mpi_lset( &T1, 0 ) );
            T1.p[0] = (t < 1) ? 0 : Y.p[t - 1];
            T1.p[1] = Y.p[t];
            CHK( mpi_mul_int( &T1, &T1, Z.p[i - t - 1] ) );

            CHK( mpi_lset( &T2, 0 ) );
            T2.p[0] = (i < 2) ? 0 : X.p[i - 2];
            T2.p[1] = (i < 1) ? 0 : X.p[i - 1];
            T2.p[2] = X.p[i];
        }
        while( mpi_cmp_mpi( &T1, &T2 ) > 0 );

        CHK( mpi_mul_int( &T1, &Y, Z.p[i - t - 1] ) );
        CHK( mpi_shift_l( &T1,  biL * (i - t - 1) ) );
        CHK( mpi_sub_mpi( &X, &X, &T1 ) );

        if( mpi_cmp_int( &X, 0 ) < 0 )
        {
            CHK( mpi_copy( &T1, &Y ) );
            CHK( mpi_shift_l( &T1, biL * (i - t - 1) ) );
            CHK( mpi_add_mpi( &X, &X, &T1 ) );
            Z.p[i - t - 1]--;
        }
    }

    if( Q != NULL )
    {
        mpi_copy( Q, &Z );
        Q->s = A->s * B->s;
    }

    if( R != NULL )
    {
        mpi_shift_r( &X, k );
        mpi_copy( R, &X );

        R->s = A->s;
        if( mpi_cmp_int( R, 0 ) == 0 )
            R->s = 1;
    }

cleanup:

    mpi_free( &X, &Y, &Z, &T1, &T2, NULL );
    return( ret );
}

/*
 * Modulo: X = A mod N
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_DIVISION_BY_ZERO if N == 0
 */
int mpi_mod_mpi( mpi *R, mpi *A, mpi *B )
{
    int ret;

    CHK( mpi_div_mpi( NULL, R, A, B ) );

    while( mpi_cmp_int( R, 0 ) < 0 )
      CHK( mpi_add_mpi( R, R, B ) );

    while( mpi_cmp_mpi( R, B ) >= 0 )
      CHK( mpi_sub_mpi( R, R, B ) );

cleanup:

    return( ret );
}

/* 
 * Fast Montgomery initialization (thanks to Tom St Denis)
 */
void mpi_montg_init( t_int *mm, mpi *N )
{
    t_int x, m0 = N->p[0];

    x  = m0;
    x += ((m0 + 2) & 4) << 1;
    x *= (2 - (m0 * x));

    if( biL >= 16 ) x *= (2 - (m0 * x));
    if( biL >= 32 ) x *= (2 - (m0 * x));
    if( biL >= 64 ) x *= (2 - (m0 * x));

    *mm = ~x + 1;
}

/* 
 * Montgomery multiplication: X = A * B * R^-1 mod N  (HAC 14.36)
 * (Z is a decoy used to prevent timing attacks)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_montgomery( mpi *X, mpi *A, mpi *B, mpi *N, mpi *Z, t_int mm )
{
    int ret, i, maxB;
    t_int j;
    t_int u0, *x0, z = 1;
    t_int u1, *x1;
    mpi U;

    U.s = U.n = 1; U.p = &z;

    if( A == NULL ) A = &U;
    if( B == NULL ) B = &U;

    CHK( mpi_grow( X, N->n + 2 ) );
    CHK( mpi_lset( X, 0 ) );

    maxB = ( B->n > N->n ) ? N->n : B->n;

    for( i = 0; i < N->n; i++ )
    {
        /*
         * X = X + u0*B + u1*M
         */
        u0 = ( i < A->n ) ? A->p[i] : 0;
        u1 = ( X->p[0] + u0 * B->p[0] ) * mm;

        MULADDC( maxB, B->p, X->p, u0 );
        MULADDC( N->n, N->p, X->p, u1 );

        /*
         * right-shift X by one limb
         */
        x0 = X->p;
        x1 = X->p + 1;

        for( j = X->n - 1; j > 0; j-- )
            *x0++ = *x1++;

        *x0 = 0;
    }

    CHK( mpi_copy( Z, N ) );

    if( mpi_cmp_abs( X, N ) >= 0 )
        { CHK( mpi_sub_abs( X, X, N ) ); }
    else
        { CHK( mpi_sub_abs( Z, Z, X ) ); }

cleanup:

    return( ret );
}

/*
 * Sliding-window exponentiation: X = A^E mod N  (HAC 14.85)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_INVALID_PARAMETER if N is negative or even
 */
int mpi_exp_mod( mpi *X, mpi *A, mpi *E, mpi *N )
{
    int ret, i, j, wsize, wbits, nbits;
    int bufsize, nblimbs, state;
    mpi R, S, T, W[64], Z;
    t_int mm, ei;

    if( mpi_cmp_int( N, 0 ) < 0 || ( N->p[0] & 1 ) == 0 )
        return( ERR_MPI_INVALID_PARAMETER );

    mpi_init( &Z, &R, &S, &T, NULL );
    memset( W, 0, sizeof( W ) );

    /*
     * S = R mod N
     */
    CHK( mpi_lset( &R, 1 ) );
    CHK( mpi_shift_l( &R, N->n * biL ) );
    CHK( mpi_mod_mpi( &S, &R, N ) );

    /*
     * W[1] = A * R mod N
     */
    CHK( mpi_copy( &R, A ) );
    CHK( mpi_shift_l( &R, N->n * biL ) );
    CHK( mpi_mod_mpi( &W[1], &R, N ) );

    i = mpi_size( E );

    wsize = ( i > 671 ) ? 6 :
            ( i > 239 ) ? 5 :
            ( i >  79 ) ? 4 :
            ( i >  23 ) ? 3 : 2;

    mpi_montg_init( &mm, N );

    if( wsize > 1 )
    {
        /*
         * W[1 << (wsize - 1)] = W[1] ^ (wsize - 1)
         */
        j =  1 << (wsize - 1);

        CHK( mpi_copy( &W[j], &W[1] ) );

        for( i = 0; i < wsize - 1; i++ )
        {
            CHK( mpi_montgomery( &T, &W[j], &W[j], N, &Z, mm ) );
            CHK( mpi_copy( &W[j], &T ) );
        }
    
        /*
         * W[i] = W[1] * W[i - 1]
         */
        for( i = j + 1; i < (1 << wsize); i++ )
        {
            CHK( mpi_montgomery( &T, &W[i - 1], &W[1], N, &Z, mm ) );
            CHK( mpi_copy( &W[i], &T ) );
        }
    }

    nblimbs = E->n;
    bufsize = 0;
    nbits   = 0;
    wbits   = 0;
    state   = 0;

    while( 1 )
    {
        if( bufsize == 0 )
        {
            if( nblimbs-- == 0 )
                break;

            bufsize = sizeof( t_int ) << 3;
        }

        bufsize--;

        ei = (E->p[nblimbs] >> bufsize) & 1;

        /*
         * skip leading 0s
         */
        if( ei == 0 && state == 0 )
            continue;

        if( ei == 0 && state == 1 )
        {
            /*
             * out of window, square S
             */
            CHK( mpi_montgomery( &T, &S, &S, N, &Z, mm ) );
            CHK( mpi_copy( &S, &T ) );
            continue;
        }

        /*
         * add ei to current window
         */
        state = 2;

        nbits++;
        wbits |= (ei << (wsize - nbits));

        if( nbits == wsize )
        {
            /*
             * S = S^wsize R^-1 mod N
             */
            for( i = 0; i < wsize; i++ )
            {
                CHK( mpi_montgomery( &T, &S, &S, N, &Z, mm ) );
                CHK( mpi_copy( &S, &T ) );
            }

            /*
             * S = S * W[wbits] R^-1 mod N
             */
            CHK( mpi_montgomery( &T, &S, &W[wbits], N, &Z, mm ) );
            CHK( mpi_copy( &S, &T ) );

            state--;
            nbits = 0;
            wbits = 0;
        }
    }

    /*
     * process the remaining bits
     */
    for( i = 0; i < nbits; i++ )
    {
        CHK( mpi_montgomery( &T, &S, &S, N, &Z, mm ) );
        CHK( mpi_copy( &S, &T ) );

        wbits <<= 1;

        if( (wbits & (1 << wsize)) != 0 )
        {
            CHK( mpi_montgomery( &T, &S, &W[1], N, &Z, mm ) );
            CHK( mpi_copy( &S, &T ) );
        }
    }

    /*
     * X = A^E * R * R^-1 mod N = A^E mod N
     */
    CHK( mpi_montgomery( &T, &S, NULL, N, &Z, mm ) );
    CHK( mpi_copy( X, &T ) );

    if( wsize > 1 )
        for( i = (1 << (wsize - 1));
             i < (1 << wsize); i++ )
            mpi_free( &W[i], NULL );

cleanup:

    mpi_free( &Z, &W[1], &R, &S, &T, NULL );
    return( ret );
}

/*
 * Greatest common divisor  (HAC 14.54)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_gcd( mpi *G, mpi *A, mpi *B )
{
    int ret;
    uint count;
    mpi TG, TA, TB;

    mpi_init( &TG, &TA, &TB, NULL );

    CHK( mpi_lset( &TG, 1 ) );
    CHK( mpi_copy( &TA, A ) );
    CHK( mpi_copy( &TB, B ) );

    TA.s = TB.s = 1;

    count = ( mpi_lsb( &TA ) < mpi_lsb( &TB ) )
            ? mpi_lsb( &TA ) : mpi_lsb( &TB );

    CHK( mpi_shift_l( &TG, count ) );
    CHK( mpi_shift_r( &TA, count ) );
    CHK( mpi_shift_r( &TB, count ) );

    while( mpi_cmp_int( &TA, 0 ) != 0 )
    {
        while( ( TA.p[0] & 1 ) == 0 ) CHK( mpi_shift_r( &TA, 1 ) );
        while( ( TB.p[0] & 1 ) == 0 ) CHK( mpi_shift_r( &TB, 1 ) );

        if( mpi_cmp_mpi( &TA, &TB ) >= 0 )
        {
            CHK( mpi_sub_abs( &TA, &TA, &TB ) );
            CHK( mpi_shift_r( &TA, 1 ) );
        }
        else
        {
            CHK( mpi_sub_abs( &TB, &TB, &TA ) );
            CHK( mpi_shift_r( &TB, 1 ) );
        }
    }

    CHK( mpi_mul_mpi( G, &TG, &TB ) );

cleanup:

    mpi_free( &TB, &TA, &TG, NULL );
    return( ret );
}

