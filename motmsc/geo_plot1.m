
% get an allgeo file
% load ../../data/2012/daily/allgeo20120519.mat
load ../../data/2013/daily/allgeo20130312.mat

% microseconds/hour, conversion factor for plots
us_hr = 1e6 * 60 * 60;

% drop scans with obvious bad data
ix = find(min(allgeo.FORTime) > 1e12);

t15 = squeeze(allgeo.FORTime(15,ix));

lat15 = squeeze(allgeo.Latitude(5,15,ix)); 
	
lon15 = squeeze(allgeo.Longitude(5,15,ix)); 

figure(1)
clf

t0 = (double(t15) - double(t15(1))) / us_hr;

plot(t0, lat15, t0, lon15)
legend('latitude', 'longitude') 
grid
zoom on

return	

plot(t0(2:end), diff(lat15))

subplot(2,1,1)
plot(t15 - t15(1), lat15)
title('latitude')

subplot(2,1,2)
plot(t15 - t15(1), lon15)
title('longitude')

