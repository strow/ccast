%
% noaa_test5 -- 3-way matchup: kcarta, rtp, and cris SDR
%
% test5_flat1 - flat calc, sdr60_hr obs
% test5_flat2 - flat calc, c0_Pn_ag obs
% test5_resp1 - resp calc, sdr60_hr obs
% test5_resp2 - resp calc, c0_Pn_ag obs
%

addpath /asl/matlib/h4tools
addpath time

% load convolved kcarta data
% d1 = load('test3_flat');
  d1 = load('test3_resp');
vkLW = d1.frqLW;  bkLW = rad2bt(vkLW, d1.radLW);
vkMW = d1.frqMW;  bkMW = rad2bt(vkMW, d1.radMW);
vkSW = d1.frqSW;  bkSW = rad2bt(vkSW, d1.radSW);

% read the rtp data
rdir = '/asl/s1/motteler/data/noaa_test';
rtpfile = fullfile(rdir, 'rtp_d20150218_t0318115.rtp');
[h, ha, p, pa] = rtpread(rtpfile);

% load the clear index
load iclear
nobs = length(iclear);

% take the clear subset
vrtp = h.vchan;
brtp = rad2bt(vrtp, p.rcalc(:, iclear));
rtime = p.rtime(iclear);
ifov = p.ifov(iclear);
xtrack = p.xtrack(iclear);

% match rtp and convolved kcarta grids
[ix, jx] = seq_match(vrtp, vkLW); 
vrLW = vrtp(ix);  brLW = brtp(ix, :);
vkLW = vkLW(jx);  bkLW = bkLW(jx, :);
[ix, jx] = seq_match(vrtp, vkMW); 
vrMW = vrtp(ix);  brMW = brtp(ix, :);
vkMW = vkMW(jx);  bkMW = bkMW(jx, :);
[ix, jx] = seq_match(vrtp, vkSW); 
vrSW = vrtp(ix);  brSW = brtp(ix, :);
vkSW = vkSW(jx);  bkSW = bkSW(jx, :);

% load the sdr data
% sdir = '/asl/data/cris/ccast/sdr60_hr/2015/049';
  sdir = '/asl/data/cris/ccast/c0_Pn_ag/2015/049';
d2 = load(fullfile(sdir, 'SDR_d20150218_t0318115'));
stime = iet2tai(d2.geo.FORTime);
jLW = seq_match(d2.vLW, vkLW);  vsLW = d2.vLW(jLW);
jMW = seq_match(d2.vMW, vkMW);  vsMW = d2.vMW(jMW);
jSW = seq_match(d2.vSW, vkSW);  vsSW = d2.vSW(jSW);

% match rtp and sdr times
bsLW = ones(length(jLW), nobs) * NaN;
bsMW = ones(length(jMW), nobs) * NaN;
bsSW = ones(length(jSW), nobs) * NaN;

for k = 1 : nobs
  for j = 1 : 60
    for i = 1 : 30
      if  xtrack(k) == i && isclose(stime(i,j), rtime(k))
        mfov = ifov(k);
        mtime = rtime(k);
        bsLW(:, k) = rad2bt(vsLW, d2.rLW(jLW, ifov(k), i, j));
        bsMW(:, k) = rad2bt(vsMW, d2.rMW(jMW, ifov(k), i, j));
        bsSW(:, k) = rad2bt(vsSW, d2.rSW(jSW, ifov(k), i, j));
      end
    end
  end
  if mod(k, 100) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

% tstr = 'flat sdr60_hr';
% tstr = 'flat c0_Pn_ag';
% tstr = 'resp sdr60_hr';
  tstr = 'resp c0_Pn_ag';

save test5_resp2 bsLW bsMW bsSW vsLW vsMW vsSW ...
                 brLW brMW brSW vrLW vrMW vkSW ...
                 bkLW bkMW bkSW vkLW vkMW vkSW ...
                 rtime stime ifov xtrack tstr

