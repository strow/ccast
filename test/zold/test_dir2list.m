

flist = dir2list('RCRIS', 'GCRSO', 60);

flist = dir2list('GCRSO', 'RCRIS', 60);

flist = dir2list('GCRSO', 'GCRSO', 4);

flist = dir2list('RCRIS', 'RCRIS', 4);

flist = dir2list('GCRSO', 'GCRSO', 60);

flist = dir2list('RCRIS', 'RCRIS', 60);

snppdir = '/asl/data/cris/rdr60/2017/181';
flist = dir2list(snppdir, 'RCRIS', 60);

j1dir = '/asl/data/cris2/CRIS-SCIENCE-RDR_SPACECRAFT-DIARY-RDR/20171203';
flist = dir2list(j1dir, 'RCRIS', 4);

