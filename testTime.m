
dsrc = '/home/motteler/cris/test2/2010/09/06';

dlist = dir(sprintf('%s/RDR*.mat', dsrc));

tlist = 2*length(dlist);

if ~isempty(dlist)
  for i = 1 : length(dlist)

    mfile = [dsrc, '/', dlist(i).name];
    load(mfile)

    % the load gets instrument and meta data from the call
    % [d1, m1] = read_cris_hdf5_rdr(h5file);

    t1 = m1.CRIS_SCIENCE_RDR.N_Beginning_Time_IET;
    t2 = m1.CRIS_SCIENCE_RDR.N_Ending_Time_IET;

    tlist(2*(i-1) + 1) = t1;
    tlist(2*(i-1) + 2) = t2;

  end
end

plot(tlist)

