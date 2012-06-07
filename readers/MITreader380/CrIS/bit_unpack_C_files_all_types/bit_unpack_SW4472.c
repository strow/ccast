/* bit_unpack_SW.c - Program for unpacking "bit-trimmed" igm's 
 *
 * Revision History
 *
 * 12 Jul 2004 (WJB) bit mask tables taken from "CrIS Command and
 *                   Data Packet Dictionary", ITT Doc. #8196185 (RevA)
 *                   4/15/04
 *
 * 09 Feb 2006 bit mask was changed in Jan05 (WJB)
 *
 */

#include "mex.h"
#define NUM_IGMS 799
#define NUM_WORDS 811
#define NUM_BITS 23

void bit_unpack(double *input, double *output)
{
  int i,j,word_counter = 0, bit_start=1, bit_end=1, current_num_bits;
  int igm_counter = 0, output_int, output_int_tmp1, output_int_tmp2; 
  int bits_to_shift;
  int mask=0;
  int sign_bit;
  double bits_to_trim[NUM_IGMS+1];  

  for (i = 1; i <= 166; i++) {
	bits_to_trim[i] = 1;
      }
  for (i = 167; i <= 305; i++) {
	bits_to_trim[i] = 1;
      }
  for (i = 306; i <= 494; i++) {
	bits_to_trim[i] = 0;
      }
  for (i = 495; i <= 637; i++) {
	bits_to_trim[i] = 1;
      }
  for (i = 638; i <= 799; i++) {
	bits_to_trim[i] = 1;
      }
  while (igm_counter < NUM_IGMS) {
      current_num_bits = NUM_BITS - bits_to_trim[igm_counter+1];
      bit_end = bit_start + current_num_bits - 1;
      sign_bit = 1<<(current_num_bits-1);
      /*if (igm_counter < 35){
        printf("input[word_counter]: %g, bit_start: %d, bit_end: 
%d\n",input[word_counter], bit_start, bit_end);
      }*/
	if ( bit_end  > 32) { /* carry over into next two words */
          /* Get the remaining bits from the current word */
          output_int_tmp1 = getbits(input[word_counter], bit_start, 16);
          bits_to_shift = 16 - bit_start + 1;
          word_counter += 1;
          output_int_tmp2 = (getbits(input[word_counter], 1, 16) << 
bits_to_shift) | output_int_tmp1;
          bits_to_shift += 16;
          word_counter += 1;
          bit_start = 1;
          bit_end = bit_end - 32;
          output_int = (getbits(input[word_counter], bit_start, bit_end) << 
bits_to_shift) | output_int_tmp2;
          bit_start = bit_end+1;

      } else {
        if ( bit_end  > 16) { /* carry over into next word */
         /* Get the remaining bits from the current word */
          output_int_tmp1 = getbits(input[word_counter], bit_start, 16);
          bits_to_shift = 16 - bit_start + 1;
          word_counter += 1;
          bit_start = 1;
          bit_end = bit_end - 16;
          output_int = (getbits(input[word_counter], bit_start, bit_end) << 
bits_to_shift) | output_int_tmp1;
       /* if (igm_counter < 35){
        printf("2 output_int: %d, bit_start: %d, bit_end: %d, bits_to_shift: %d, 
foo: %d\n",output_int, bit_start, bit_end, bits_to_shift,   
getbits(input[word_counter], bit_start, bit_end) << bits_to_shift);
      } */
          bit_start = bit_end+1;

        } else {  /* enough bits in current word */
          output_int = getbits(input[word_counter], bit_start, bit_end);
          bit_start = bit_end+1;
        }
      }  
      
      if (output_int & sign_bit){
        mask = 0;
        for (j=1; j < current_num_bits; j++) {
          mask = mask|(1<<(j-1));
        }
        output[igm_counter] = (double) -(((~(output_int - (output_int & 
sign_bit))) & mask) + 1);
      } else {
        output[igm_counter] = (double) output_int;
      } 
      /* if (igm_counter < 35){
        printf("input[word_counter]: %g, bit_start: %d, bit_end: 
%d\n",input[word_counter], bit_start, bit_end);
        printf("igm_counter: %d output_int: %d sign_bit: %d output: %g\n", 
igm_counter, output_int, sign_bit, output[igm_counter]);
      } */
      igm_counter += 1;
  }
}


/* The gateway routine */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  double *x, *y;
    
  /*  Check for proper number of arguments. */
  /* NOTE: You do not need an else statement when using
     mexErrMsgTxt within an if statement. It will never
     get to the else statement if mexErrMsgTxt is executed.
     (mexErrMsgTxt breaks you out of the MEX-file.) 
  */
  if (nrhs != 1) 
    mexErrMsgTxt("One input required.");
  if (nlhs != 1) 
    mexErrMsgTxt("One output required.");
  
  /* Create a pointer to the input matrix x. */
  x = mxGetPr(prhs[0]);
  
  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(1,NUM_IGMS, mxREAL);
  
  /* Create a C pointer to a copy of the output matrix. */
  y = mxGetPr(plhs[0]);
  
  /* Call the C subroutine. */
  bit_unpack(x,y);
}

int getbits(double x, int bit_start, int bit_end)
{
  unsigned short j, mask = 0;
  for (j=bit_start; j <= bit_end; j++) {
    mask = mask|(1<<(j-1));
  }
  /* printf("mask:  %d\n", mask); */
  return (int) (((unsigned short) x) & mask) >> (bit_start-1);

} 

