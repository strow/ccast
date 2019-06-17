% 
% compare geo.Asc_Desc_Flag and max lat for north polar 
% crossing times
%

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

cdir = '/asl/cris/ccast/sdr45_npp_HR/2018';
dlist = 91:92
iFOV = 5;
iFOR = 16;

lat_list = [];
lon_list = [];
tai_list = [];
asc_list = logical([]);

% loop on days of the year
for di = dlist
  
  % loop on CrIS granules
  doy = sprintf('%03d', di);
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(cdir, doy, '*SDR*.mat'));
  for fi = 1 : length(flist);
    if mod(fi, 10) == 0, fprintf(1, '.'), end
    cfile = fullfile(cdir, doy, flist(fi).name);
    d1 = load(cfile, 'geo');

    lat = squeeze(d1.geo.Latitude(iFOV,iFOR,:));
    lon = squeeze(d1.geo.Longitude(iFOV,iFOR,:));
    tai = iet2tai(d1.geo.FORTime(iFOR,:))';
    asc = d1.geo.Asc_Desc_Flag;

    gOK = -90 <= lat & lat <=  90 & ...
         -180 <= lon & lon <= 180 & ...
         ~isnan(asc);

    lat = lat(gOK);
    lon = lon(gOK);
    tai = tai(gOK);
    asc = asc(gOK);

    lat_list = [lat_list; lat];
    lon_list = [lon_list; lon];
    tai_list = [tai_list; tai];
    asc_list = [asc_list; asc];
 
  end % loop on granules
  fprintf(1, '\n')
end % loop on days

mlat = movavg1(lat_list, 3);
% plot(mlat)

% tax = tai2dnum(tai_list);
% tax = datetime(tax, 'ConvertFrom', 'datenum');
% tax = (tai_list - tai_list(1)) / 6060;
% tax = (tai_list - tai_list(1)) / 60;
% t1 = tai_list / 6090;

t1 = tai_list;
t2 = t1 - t1(1);
dlat = diff(mlat);
% plot(t2, mlat, t2(2:end), 120*dlat)
% axis([0,28, -90, 90])
% axis([0,1.73e5, -90, 90])
% grid on

nlist = [];
ilist = [];
i1 = find(mlat > 80, 1)
n = length(mlat);
while ~isempty(i1)
  i2 = i1 + 32;
  if i2 > n, i2 = n; end
  [~,j1] = max(mlat(i1:i2));
  [~,j2] = min(abs(dlat(i1:i2)));
  ilist = [ilist, [i1, i2]'];
  nlist = [nlist, [j1+i1-1,j2+i1-1]'];
  i1 = find(mlat(i2:end) > 80, 1) + i2 - 1;
end

ix1 = ilist(1,:);
ix2 = ilist(2,:);
nx1 = nlist(1,:);
nx2 = nlist(2,:);
plot(t2, mlat, t2, asc_list * 82, ...
     t2(ix1), mlat(ix1), '+r', t2(ix2), mlat(ix2), '+g', ...
     t2(nx1), mlat(nx1), 'or', t2(nx2), mlat(nx2), 'og');


