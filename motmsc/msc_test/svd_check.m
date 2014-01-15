%
% compare singular values for CrIS obs and calc radiances
% 

addpath /home/motteler/mot2008/hdf/h4tools
addpath /home/motteler/cris/bcast/motmsc/utils

% p = '/asl/data/rtprod_cris/2012/09/20'
% f = 'cris_sdr60_noaa_ops.2012.09.20.096.Rv1.1b-Mv1.1b.rtp'

p = '/asl/s1/imbiriba/git_rtp_prod_scripts_dump/data/rtprod_cris/2013/08/28';
% f = 'cris_ccast_hr.ecmwf.umw.calc.2013.08.28.091000_092000.R1.9i-1-gcedde88-Mv1.9f.rtp';
% f = 'cris_ccast_hr.ecmwf.umw.calc.2013.08.28.092000_093000.R1.9i-1-gcedde88-Mv1.9f.rtp';
  f = 'cris_ccast_hr.ecmwf.umw.calc.2013.08.28.123000_124000.R1.9i-1-gcedde88-Mv1.9f.rtp';

[head, hattr, prof, pattr] = rtpread(fullfile(p,f));

freq = head.vchan;
robs = prof.robs1;
rcal = prof.rcalc;

[m, n] = size(robs);

jok = [];
for j = 1 : n
  if isempty(find(isnan(robs(:,j)))) &&  isempty(find(isnan(rcal(:,j))))
    jok = [jok, j];
  end
end

robs = robs(:, jok);
rcal = rcal(:, jok);

k = 2000;  % points in each SVD

for i = 1 : k : n - k + 1;

  ix = i : i + k - 1;

  [u,s,v] = svd(robs(:,ix));
  sobs = diag(s);

  [u,s,v] = svd(rcal(:,ix));
  scal = diag(s);

  semilogy(1:k, sobs, 1:k, scal)
  legend('obs', 'cal')
  title('sample CrIS singular values')
  xlabel('index')
  ylabel('singular values')
  grid on; zoom on

  fprintf(1, 'i = %d\n', i)
  pause

end
