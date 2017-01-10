#ifndef _BIGNUM_H
#define _BIGNUM_H

#ifndef _STD_TYPES
#define _STD_TYPES

#define uchar   unsigned char
//#define uint    unsigned int
//#define uint32_t   unsigned long int
//uint16_t
#endif

/*
 * Default to unsigned int for the base limb type,
 * except x86_64 where uint is only 32-bit wide.
 */
#ifndef __amd64__
#define t_int uint
#else
#define t_int unsigned long long
#endif

#define ERR_MPI_INVALID_CHARACTER               0x0006
#define ERR_MPI_INVALID_PARAMETER               0x0008
#define ERR_MPI_BUFFER_TOO_SMALL                0x000A
#define ERR_MPI_NEGATIVE_VALUE                  0x000C
#define ERR_MPI_DIVISION_BY_ZERO                0x000E
#define ERR_MPI_NOT_INVERTIBLE                  0x0010
#define ERR_MPI_IS_COMPOSITE                    0x0012

#define CHK(fc) if( ( ret = fc ) != 0 ) goto cleanup

#include <stdio.h>
#include <UIKit/UIKit.h>

typedef struct
{
    int s;              /* integer sign     */
    int n;              /* total # of limbs */
    t_int *p;           /* pointer to limbs */
}
mpi;

/*
 * Initialize one or more mpi
 */
void mpi_init( mpi *X, ... );

/*
 * Unallocate one or more mpi
 */
void mpi_free( mpi *X, ... );

/*
 * Enlarge total size to the specified # of limbs
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_grow( mpi *X, int nblimbs );

/*
 * Set value to integer z
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_lset( mpi *X, int z );

/*
 * Copy the contents of Y into X
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_copy( mpi *X, mpi *Y );


/*
 * Set value from string
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_INVALID_PARAMETER if radix is not between 2 and 16
 *         ERR_MPI_INVALID_CHARACTER if a non-digit character is found
 */
int mpi_read( mpi *X, char *s, int radix );

int mpi_read_bytes( mpi *X, char *pcSrc, int nBytes );

/*
 * Import unsigned value from binary data
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_import( mpi *X, unsigned char *buf, uint buflen );

/*
 * Export unsigned value into binary data
 *
 * Call this function with buflen = 0 to obtain the required
 * buffer size in buflen.
 *
 * Returns 0 if successful
 *         ERR_MPI_BUFFER_TOO_SMALL if buf hasn't enough room
 */
int mpi_export( mpi *X, unsigned char *buf, uint *buflen );

/*
 * Returns actual size in bits
 */
uint mpi_size( mpi *X );

/*
 * Returns # of least significant bits
 */
uint mpi_lsb( mpi *X );

/*
 * Left-shift: X <<= count
 *
 * Returns 0 if successful,
 *         1 if memory allocation failed
 */
int mpi_shift_l( mpi *X, uint count );

/*
 * Right-shift: X >>= count
 *
 * Always returns 0.
 */
int mpi_shift_r( mpi *X, uint count );

/*
 * Compare absolute values
 *
 * Returns 1 if |X| is greater than |Y|
 *        -1 if |X| is lesser  than |Y|
 *         0 if |X| is equal to |Y|
 */
int mpi_cmp_abs( mpi *X, mpi *Y );

/*
 * Compare signed values
 *
 * Returns 1 if X is greater than Y
 *        -1 if X is lesser  than Y
 *         0 if X is equal to Y
 */
int mpi_cmp_mpi( mpi *X, mpi *Y );

/*
 * Compare signed values
 *
 * Returns 1 if X is greater than z
 *        -1 if X is lesser  than z
 *         0 if X is equal to z
 */
int mpi_cmp_int( mpi *X, int z );

/*
 * Unsigned addition: X = |A| + |B|  (HAC 14.7)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_add_abs( mpi *X, mpi *A, mpi *B );

/*
 * Unsigned substraction: X = |A| - |B|  (HAC 14.9)
 *
 * Returns 0 if successful
 *         ERR_MPI_NEGATIVE_VALUE if B is greater than A
 */
int mpi_sub_abs( mpi *X, mpi *A, mpi *B );

/*
 * Signed addition: X = A + B
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_add_mpi( mpi *X, mpi *A, mpi *B );

/*
 * Signed substraction: X = A - B
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_sub_mpi( mpi *X, mpi *A, mpi *B );

/*
 * Signed addition: X = A + b
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_add_int( mpi *X, mpi *A, int b );

/*
 * Signed substraction: X = A - b
 *
 * Returns 0 if successful,
 *         1 if memory allocation failed
 */
int mpi_sub_int( mpi *X, mpi *A, int b );

/*
 * Baseline multiplication: X = A * B  (HAC 14.12)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_mul_mpi( mpi *X, mpi *A, mpi *B );

/*
 * Baseline multiplication: X = A * b
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_mul_int( mpi *X, mpi *A, t_int b );

/*
 * Division by mpi: A = Q * B + R  (HAC 14.20)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_DIVISION_BY_ZERO if B == 0
 */
int mpi_div_mpi( mpi *Q, mpi *R, mpi *A, mpi *B );

/*
 * Modulo: X = A mod N
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_DIVISION_BY_ZERO if N == 0
 */
int mpi_mod_mpi( mpi *R, mpi *A, mpi *B );

/*
 * Sliding-window exponentiation: X = A^E mod N  (HAC 14.85)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 *         ERR_MPI_INVALID_PARAMETER if N is negative or even
 */
int mpi_exp_mod( mpi *X, mpi *A, mpi *E, mpi *N );

/*
 * Greatest common divisor  (HAC 14.54)
 *
 * Returns 0 if successful
 *         1 if memory allocation failed
 */
int mpi_gcd( mpi *G, mpi *A, mpi *B );

#endif /* mpi.h */
