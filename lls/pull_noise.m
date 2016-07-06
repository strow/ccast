cd /asl/s1/strow/ccast/2016/018
a = dir('*.mat');

for i=1:length(a)
   i
   load(a(i).name);
   n(i).rLW = rLW;
   n(i).rMW = rMW;
   n(i).rSW = rSW;
   n(i).Latitude = geo.Latitude;
   n(i).Longitude = geo.Longitude;
   n(i).FORTime = geo.FORTime;
   n(i).Asc_Desc_Flg = geo.Asc_Desc_Flag;
   n(i).SatelliteZenithAngle = geo.SatelliteZenithAngle;
end

