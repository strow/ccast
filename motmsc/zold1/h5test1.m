
% split up a fat h5 granule

dsrc = '/asl/data/cris/Proxy/2010/09/06';

dlist = dir(sprintf('%s/RCRIS-RNSCA_npp*.h5', dsrc));

ix = 20;

h5in = [dsrc, '/', dlist(ix).name];

dd = h5info(h5in, '/All_Data/CRIS-SCIENCE-RDR_All/');

% for iy = 1 : length(dd.Datasets)
for iy = 1

  h5GroupData = h5read(h5in, ...
    sprintf('/All_Data/CRIS-SCIENCE-RDR_All/RawApplicationPackets_%d',iy-1));

end

h5out = 'test.h5';
delete(h5out)

[m,n] = size(h5GroupData);

h5create(h5out, ...
         '/All_Data/CRIS-SCIENCE-RDR_All/RawApplicationPackets_0', ...
         [m,n]);

h5write(h5out, ...
        '/All_Data/CRIS-SCIENCE-RDR_All/RawApplicationPackets_0', ...
         h5GroupData);

addpath /home/motteler/cris/MITreader09
addpath /home/motteler/cris/MITreader09/CrIS

% [d1, m1] = read_cris_hdf5_rdr(h5out);
d2 = read_cris_hdf5_rdrYY(h5out);

rmpath /home/motteler/cris/MITreader09
rmpath /home/motteler/cris/MITreader09/CrIS

addpath /home/motteler/cris/MITreader12
addpath /home/motteler/cris/MITreader12/CrIS

[d1, m1] = read_cris_hdf5_rdr(h5in);


x1 = (iy-1)*120+1;
x2 = x1 + 120 - 1;

isequal(d2.idata.LWES(:,:,1:120), d1.idata.LWES(:,:, x1:x2))

% isequal(d2.idata.LWES(:,:,1:120), d1.idata.LWES(:,:, 241:360))
