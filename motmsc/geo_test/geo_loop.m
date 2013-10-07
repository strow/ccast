
more off

gdir{1} = '/home/motteler/cris/data/2012/daily/';
flist{1} = dir(fullfile(gdir{1}, 'allgeo*.mat'));
flist{1} = flist{1}(34:end);  % start 1 apr 2012

gdir{2} = '/home/motteler/cris/data/2013/daily/';
flist{2} = dir(fullfile(gdir{2}, 'allgeo*.mat'));

time = [];
lat  = [];
lon  = [];
adflag = [];

for j = 1 : length(flist)
  for i = 1 : length(flist{j});
    fprintf(1, 'loading %s\n', flist{j}(i).name);
    gfile = [gdir{j},flist{j}(i).name];

    d1 = load(gfile);
  
    tx = double(d1.allgeo.FORTime(15, :));
    time = [time; tx(:)];
  
    tx = double(d1.allgeo.Latitude(5,15, :));
    lat = [lat; tx(:)];
  
    tx = double(d1.allgeo.Longitude(5,15, :));
    lon = [lon; tx(:)];
  
    tx = d1.allgeo.Asc_Desc_Flag;
    adflag = [adflag; tx];
  end
end

% clean up
iok = find(time(1) <= time & lat > -100 & lon > -200);
time = time(iok);
lat = lat(iok);
lon = lon(iok);
adflag = adflag(iok);

save geo_loop time lat lon adflag

whos time lat lon adflag
figure(1); clf; plot(time, lat); grid on; zoom on;
figure(2); clf; plot(time, lon); grid on; zoom on;

