/*
 * ccsds demo reader
 *
 * duplicates the behavior of read_ccsds_v1.m
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

/* Byte swap unsigned short
 */
uint16_t swap_uint16( uint16_t val ) 
{
    return (val << 8) | (val >> 8 );
}

main (int argc, char *argv[]) {

  int i, j, k, m, n, c;
  float *a1, *a2, *b, t, u, v;
  FILE *pin, *pout;
  int nrows, ncols;
  int sgn = 0;                  /* default 0                    */
  int npr = 4;                  /* default number of threads    */
  char *fin="test_in.dat";      /* default input file name      */
  char *fout="test_out.dat";    /* default output file name     */
  uint16_t buf[3], sbuf[4];
  uint16_t *p;
  char ch;
  int plength;
  int day, usec_of_msec;
  long int msec_of_day;

  /* declarations for getopt */
  extern char *optarg;
  extern int optind, opterr, optopt;

  struct {
    unsigned int APID           : 11;
    unsigned int sec_head_flag  :  1;
    unsigned int type           :  1;
    unsigned int version        :  3;

    unsigned int seq_count      : 14;
    unsigned int seq_flags      :  2;

    uint16_t length;
  } packet_head;

  /* process command-line parameters
   */
  while ((c = getopt(argc, argv, "s:p:i:o:")) != EOF)
    switch (c) {
      case 's':
        sgn = atoi(optarg);
        break;
      case 'p':
        npr = atoi(optarg);
        break;
      case 'i':
        fin = malloc(strlen(optarg));
        strcpy(fin, optarg);
        break;
      case 'o':
        fout = malloc(strlen(optarg));
        strcpy(fout, optarg);
        break;
      case '?':
        fprintf(stderr, "fftest: bad option, exiting...\n");
        exit(1);
        break;
    }
 
  fprintf(stdout, "ptest: fin=%s fout=%s\n", fin, fout);
  /*
  fprintf(stdout, "ptest: sgn=%d, npr=%d, fin=%s fout=%s\n", sgn, npr, fin, fout);
  fprintf(stdout, "ptest: sizeof(packet_head) %d\n", sizeof(packet_head));
  fprintf(stdout, "ptest: sizeof(ch) %d\n", sizeof(ch));
  */

  /* open input file */
  if ((pin=fopen(fin, "r")) == NULL) {
    fprintf(stderr, "fftest: can't open %s\n", fin);
    exit(1);
  }

  for(j = 0; 1; j++) {

    fread(&buf, 2, 3, pin);
    if (feof(pin)) break;

    p = (uint16_t *) &packet_head;
    for (i = 0; i < 3; i++) p[i] = swap_uint16(buf[i]);

    plength = packet_head.length + 1;

    fprintf(stdout, "version %d, type %d, sec_head_flag %d, APID %d\n",
            packet_head.version,
            packet_head.type,
            packet_head.sec_head_flag,
            packet_head.APID);

    fprintf(stdout, "seq_flags %d, seq_count %d, length %d\n", 
            packet_head.seq_flags,
            packet_head.seq_count,
            plength);

    if (packet_head.sec_head_flag) {
      fread(&sbuf, 2, 4, pin);
      for (i = 0; i < 4; i++) sbuf[i] = swap_uint16(sbuf[i]);
      plength = plength - 8;

      day=sbuf[0];
      /* msec_of_day=(sbuf[1]*2^16 + sbuf[2]); */
      msec_of_day=(sbuf[1]*65536L + sbuf[2]);
      usec_of_msec=sbuf[3];
      fprintf(stdout, "day %d, ms %d us %d\n", day, msec_of_day, usec_of_msec);

      /*
      seconds=(msec_of_day+ usec_of_msec*1.e-3)*1.e-3;
      timeval=datenum(0,0,days,0,0,seconds);
      fprintf(1, '%s\n', datestr(timeval+715146));
      */
    }

    /* tx = fread(fid, packet_length, 'uint8'); */

    for (i = 0;  i < plength; i++) fread(&c, 1, 1, pin);
    /* for (i = 0; (c=getc(pin)) != EOF && i < plength; i++); */

  }
  fprintf(stdout, "%d packets read\n", j);
}

