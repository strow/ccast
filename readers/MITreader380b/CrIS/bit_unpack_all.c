/* bit_unpack_all.c - Program for unpacking CrIS "bit-trimmed" interferograms
 * 12 Jul 2004 (WJB) 
 * 1 March 2013 (DLM) 
 * __________________________________________________________________________
 * 
 *  (c) Copyright 2013 Massachusetts Institute of Technology
 *  
 *  In no event shall MIT Lincoln Laboratory be liable to any party for direct, indirect,
 *  special, incidental, or consequential damages arising out of the use of this software
 *  and its documentation, even if MIT Lincoln Laboratory has been advised of the possibility
 *  of such damage. MIT Lincoln Laboratory specifically disclaims any warranties including,
 *  but not limited to, the implied warranties of merchantability, fitness for a particular
 *  purpose, and non-infringement.
 *  
 *  The software is provided on an "as is" basis and MIT Lincoln Laboratory has no obligation
 *  to provide maintenance, support, updates, enhancements, or modifications.  
 * __________________________________________________________________________
 * call the program: 
 * data_unpacked=bit_unpack_all(data_packed,BitTrimIndex,BitTrimBitsRetained)
 * where
 * BitTrimIndex(:,1)=packet.BitTrimMask.Band(band).Index 
 * BitTrimBitsRetained(:,1)=packet.BitTrimMask.Band(band).StopBit-BitTrimMask.Band(band).StartBit+1;
 */

#include "mex.h"

/* The gateway routine */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
                 
{
    double *BitsRetained, *Index;
    double *input, *output;
    int N, M;
    
    int i,j,k,k1,k2=0,idx=0,word_counter = 0, bit_start=1, bit_end=1, bits_retained_now;
    int output_counter = 0, output_int, output_int_tmp1, output_int_tmp2; 
    int bits_to_shift;
    int mask=0;
    int sign_bit;
  
  /*  Check for proper number of arguments. */

  if (nrhs != 3) {
    mexErrMsgTxt("Three inputs required.");}
  if (nlhs != 1) {
    mexErrMsgTxt("One output required.");}
    
    M = mxGetM(prhs[1]);
    N = mxGetN(prhs[1]);
    /* note M=16 but indexed 0:15*/
    if (N != 1 | M != 16) {
    mexErrMsgTxt("input BitTrimIndex must be sized [16,1].");}
 
    M = mxGetM(prhs[2]);
    N = mxGetN(prhs[2]);
  if (N != 1 | M != 16)  {  
    mexErrMsgTxt("input BitTrimBitsRetained must be sized [16,1].");} 
    
  /* Create a pointer to the input matrices. */
  input = mxGetPr(prhs[0]);
  Index=mxGetPr(prhs[1]);
  BitsRetained=mxGetPr(prhs[2]);

   if (Index[15] > 2000)  {  
   mexPrintf("\ninput BitTrimIndex[15] = %g\n ",Index[15]);   
   mexErrMsgTxt("Index[15] is too big.\n");  }
  
  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(1,Index[15], mxREAL);
  
  /* Create a C pointer to a copy of the output matrix. */
  output = mxGetPr(plhs[0]);
  
/* now unpack the input data */
do
{
k1=k2+1;  
k2=Index[idx];
bits_retained_now=BitsRetained[idx];

 for (k=k1;k<=k2;k++)      
         {      
         bit_end = bit_start + bits_retained_now - 1;
         sign_bit = 1<<(bits_retained_now-1);
         
         if ( bit_end  > 32) 
                   { /* carry over into next two words */
                    /* Get the remaining bits from the current word */
                    output_int_tmp1 = getbits(input[word_counter], bit_start, 16);
                    bits_to_shift = 16 - bit_start + 1;
                    word_counter += 1;
                    output_int_tmp2 = (getbits(input[word_counter], 1, 16) << bits_to_shift) | output_int_tmp1;
                    bits_to_shift += 16;
                    word_counter += 1;
                    bit_start = 1;
                    bit_end = bit_end - 32;
                    output_int = (getbits(input[word_counter], bit_start, bit_end) << bits_to_shift) | output_int_tmp2;
                    bit_start = bit_end+1;
                    }
             else
                    {
                         if ( bit_end  > 16) 
                            { /* carry over into next word */
                             /* Get the remaining bits from the current word */ 
                            output_int_tmp1 = getbits(input[word_counter], bit_start, 16);
                            bits_to_shift = 16 - bit_start + 1;
                            word_counter += 1;
                            bit_start = 1;
                            bit_end = bit_end - 16;
                            output_int = (getbits(input[word_counter], bit_start, bit_end) << bits_to_shift) | output_int_tmp1;
                            bit_start = bit_end+1;
                            }
                        else
                            {  /* enough bits in current word */
                            output_int = getbits(input[word_counter], bit_start, bit_end);
                            bit_start = bit_end+1;
                            }
             }

              if (output_int & sign_bit)
                  {
                    mask = 0;
                    for (j=1; j < bits_retained_now; j++)
                        {mask = mask|(1<<(j-1));}
                    output[output_counter] = (double) -(((~(output_int - (output_int & sign_bit))) & mask) + 1);
                  }
              else 
                  {
                    output[output_counter] = (double) output_int;
                  }
         
              output_counter += 1;
            } 

         idx=idx+1;
         
} /* do */
while ((k2<Index[15]) & (idx<15)); 

} /* void mexFunction */
 



int getbits(double x, int bit_start, int bit_end)
{
  unsigned short j, mask = 0;
  for (j=bit_start; j <= bit_end; j++) {
    mask = mask|(1<<(j-1));
  }
  /* printf("mask:  %d\n", mask); */
  return (int) (((unsigned short) x) & mask) >> (bit_start-1);

} 
