% Just fill variables here, do commented out stuff at home.
clear

addpath ~/Matlab/Math
addpath /asl/matlab2012/cris/unapod

ifov = 2;
fnout = '/asl/s1/strow/Data/cris_ict_sa_fov2';
%fnout = '/asl/s1/strow/Data/cris_ict_nosa_fov1';

%cd /asl/s1/strow/ccast/2016/018/No_SA
cd /asl/s1/strow/ccast/2016/018/SA_applied

a = dir('*.mat');
% nfiles = length(a);
nfiles = 179;
nscans = 59;

for i=1:nfiles
   load(a(i).name);
   g(i).rLW = rLW;
   g(i).rMW = rMW;
   g(i).rSW = rSW;
   g(i).Latitude = geo.Latitude;
   g(i).Longitude = geo.Longitude;
   g(i).FORTime = geo.FORTime;
   g(i).Asc_Desc_Flg = geo.Asc_Desc_Flag;
   g(i).SatelliteZenithAngle = geo.SatelliteZenithAngle;
end

% once in a while no 60, stop at 59
for i=1:nfiles
   alllw(:,:,i)    = squeeze(g(i).rLW(:,ifov,1,1:nscans));
   allmw(:,:,i)    = squeeze(g(i).rMW(:,ifov,1,1:nscans));
   allsw(:,:,i)    = squeeze(g(i).rSW(:,ifov,1,1:nscans));
   % Pick as latitude close to nadir == "15" below
   alllat(:,i)     = squeeze(g(i).Latitude(ifov,15,1:nscans));
   alllon(:,i)     = squeeze(g(i).Longitude(ifov,15,1:nscans));
   allFORTime(:,i) = squeeze(g(i).FORTime(15,1:nscans));
   allAsc(:,i)     = squeeze(g(i).Asc_Desc_Flg(1:nscans));
   allsatzen(:,i)  = squeeze(g(i).SatelliteZenithAngle(ifov,15,1:nscans));
end

% Merge variables
n = nfiles*nscans;
lat = reshape(alllat,1,n);
lon = reshape(alllon,1,n);
satzen = reshape(allsatzen,1,n);
FORTime = reshape(allFORTime,1,n);
Asc = reshape(allAsc,1,n);

nlw = length(vLW);
nmw = length(vMW);
nsw = length(vSW);

lwr = reshape(alllw,nlw,n);
mwr = reshape(allmw,nmw,n);
swr = reshape(allsw,nsw,n);

save(fnout,'lat','lon','satzen','FORTime','satzen','Asc','lwr','mwr','swr');


% %---------- LongWave
% lwr_h = box_to_ham(lwr);
% 
% % Remove mean before SSA
% lwrm = nanmean(lwr,2);
% for i=1:n
%    lw(:,i) = lwr(:,i)-lwrm;
% end
% 
% for i=1:nlw
%    [lw_ssa(i,:),r,vr]  = ssa(lw(i,:)',500,1:10,true);
%    [lwh_ssa(i,:),r,vr] = ssa(lwh(i,:)',500,1:10,true);
% end
% disp('SSA done for LW');
% 
% lw_n = lw_ssa-lw;
% lw_cor = corrcoef(lw_n');
% lw_cov = cov(lw_n');
% 
% lwh_n = lwh_ssa-lwh;
% lwh_cor = corrcoef(lwh_n');
% lwh_cov = cov(lwh_n');
% 
% %---------- MidWave
% mwrm = nanmean(mwr,2);
% for i=1:n
%    mw(:,i) = mwr(:,i)-mwrm;
% end
% mwh = box_to_ham(mw);
% 
% for i=1:nmw
%    [mw_ssa(i,:),r,vr]  = ssa(mw(i,:)',500,1:10,true);
%    [mwh_ssa(i,:),r,vr] = ssa(mwh(i,:)',500,1:10,true);
%    i
% end
% disp('SSA done for MW');
% 
% mw_n = mw_ssa-mw;
% mw_cor = corrcoef(mw_n');
% mw_cov = cov(mw_n');
% 
% mwh_n = mwh_ssa-mwh;
% mwh_cor = corrcoef(mwh_n');
% mwh_cov = cov(mwh_n');
% 
% %---------- ShortWave
% swrm = nanmean(swr,2);
% for i=1:n
%    sw(:,i) = swr(:,i)-swrm;
% end
% swh = box_to_ham(sw);
% 
% for i=1:nsw
%    [sw_ssa(i,:),r,vr]  = ssa(sw(i,:)',500,1:10,true);
%    [swh_ssa(i,:),r,vr] = ssa(swh(i,:)',500,1:10,true);
%    i
% end
% 
% sw_n = sw_ssa-sw;
% sw_cor = corrcoef(sw_n');
% sw_cov = cov(sw_n');
% 
% swh_n = swh_ssa-swh;
% swh_cor = corrcoef(swh_n');
% swh_cov = cov(swh_n');
% 
% disp('SSA done for SW');
% 
% %---------- Save Output
% 
% save(fnout,'lat','lon','satzen','FORTime','satzen','Asc','*cor','*cov','lwr','mwr','swr');
% 
% 
% 
