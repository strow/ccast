% Pull in time series of ICT and SP looks
clear

addpath ~/Matlab/Math
addpath /asl/matlab2012/cris/unapod

ifov = 1;

fnout = '/asl/s1/strow/Data/cris_ict_sa_fov1';
%fnout = '/asl/s1/strow/Data/cris_ict_nosa_fov1';

%cd /asl/s1/strow/ccast/2016/018/SA_applied
cd /asl/s1/strow/ccast/2016/018

a = dir('SDR*.mat');
nfiles = length(a);

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
   nxtrack(i) = length(g(i).Asc_Desc_Flg);
end

% Concatenate daily data
lwict = []; mwict = []; swict = [];
lwsp = []; mwsp = []; swsp = [];
lat = []; lon = []; satzen = []; FORTime = []; Asc = [];
for i=1:nfiles
   % ICT
   lwict = cat(3,lwict, squeeze(g(i).rLW(:,ifov,29:30,:)));
   mwict = cat(3,mwict, squeeze(g(i).rMW(:,ifov,29:30,:)));
   swict = cat(3,swict, squeeze(g(i).rSW(:,ifov,29:30,:)));
   % SP
   lwsp = cat(3,lwsp, squeeze(g(i).rLW(:,ifov,27:28,:)));
   mwsp = cat(3,mwsp, squeeze(g(i).rMW(:,ifov,27:28,:)));
   swsp = cat(3,swsp, squeeze(g(i).rSW(:,ifov,27:28,:)));

   lat = cat(1,lat,squeeze(g(i).Latitude(ifov,15,:)));
   lon = cat(1,lon,squeeze(g(i).Longitude(ifov,15,:)));
   satzen = cat(1,satzen,squeeze(g(i).SatelliteZenithAngle(ifov,15,:)));
   FORTime = cat(1,FORTime,squeeze(g(i).FORTime(15,:))');
   Asc = cat(1,lat,squeeze(g(i).Asc_Desc_Flg));
end

save(fnout,'lat','lon','satzen','FORTime','Asc','lwict','mwict','swict','lwsp','mwsp','swsp');
