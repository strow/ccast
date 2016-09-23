%
% nedn_stats1 - tabulate ICT radiance from a modified ccast run
%
% this requires a mod to calmain_e5: comment out the two nedn
% assignments at the end and replace them with nedn = real(rICT);
%
% output is nedn_cat.mat
%

addpath ../source

%-----------------
% test parameters
%-----------------

sdays = 18;
tstr = 'sdr60_nedn';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

opt1 = struct;
opt1.user_res = 'lowres';
opt1.inst_res = 'hires3';
wlaser = 773.13;
[instLW, userLW] = inst_params('LW', wlaser, opt1);
[instMW, userMW] = inst_params('MW', wlaser, opt1);
[instSW, userSW] = inst_params('SW', wlaser, opt1);

vLW = cris_ugrid(userLW, 2);
vMW = cris_ugrid(userMW, 2);
vSW = cris_ugrid(userSW, 2);

ictLW = [];
ictMW = [];
ictSW = [];

%------------------------
% loop on days and files
%------------------------
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    [n1,n2,n3] = size(nLW);
    nLW = reshape(nLW, n1, n2, 2, n3/2);
    ictLW = cat(3, ictLW, squeeze(nLW(:,:,1,:)));

    [n1,n2,n3] = size(nMW);
    nMW = reshape(nMW, n1, n2, 2, n3/2);
    ictMW = cat(3, ictMW, squeeze(nMW(:,:,1,:)));

    [n1,n2,n3] = size(nSW);
    nSW = reshape(nSW, n1, n2, 2, n3/2);
    ictSW = cat(3, ictSW, squeeze(nSW(:,:,1,:)));

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

save nedn_cat ictLW ictMW ictSW vLW vMW vSW

