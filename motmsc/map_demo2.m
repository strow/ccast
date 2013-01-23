
% map demo from a list of matlab SDR files
%

% select day-of-the-year
% doy = '054';  % high-res 2nd day
% doy = '136';  % may 15 focus day
doy = '228';      % includes new geo

% path to matlab SDR input by day-of-year
SDR_mat = '/home/motteler/cris/data/2012';  

% full path to matlab SDR input files
sdir = fullfile(SDR_mat, doy);

% get matlab SDR file list
flist = dir(fullfile(sdir, 'SDR*.mat'));
nfile = length(flist);

% loop on matlab SDR files
for si = 1 : nfile

% choose a single SDR file
% for si = 24

  % full path to matlab SDR file
  rid = flist(si).name(5:22);
  stmp = ['SDR_', rid, '.mat'];
  sfile = fullfile(sdir, stmp);

  load(sfile)

  % select a channel
  ch = 373;

  [m, nscan] = size(scTime);

  % tile the FOVs
  img_re = zeros(90,3*nscan);
  img_im = zeros(90,3*nscan);
  img_lat = zeros(90,3*nscan);
  img_lon = zeros(90,3*nscan);

  for i = 1 : nscan
    for j = 1 : 30
      t_re = reshape(squeeze(real(rLW(ch,:,j,i))), 3, 3);
      t_im = reshape(squeeze(imag(rLW(ch,:,j,i))), 3, 3);
      t_lat = reshape(squeeze(geo.Latitude(:,j,i)), 3, 3);
      t_lon = reshape(squeeze(geo.Longitude(:,j,i)), 3, 3);
      j3 = 3*(j-1)+1;
      i3 = 3*(i-1)+1;
      img_re(j3:j3+2, i3:i3+2) = t_re;
      img_im(j3:j3+2, i3:i3+2) = t_im;
      img_lat(j3:j3+2, i3:i3+2) = t_lat;
      img_lon(j3:j3+2, i3:i3+2) = t_lon;
    end
  end

% end

%----------------------
% mapping toolbox plot
%----------------------

% image formats are the transpose of usual column order rep
vlat = img_lat';
vlon = img_lon';
vc  = img_re';

figure(1); clf

% select a projection
mproj = 'mercator';
% mproj = 'robinson';

% get lat/lon box to nearest degree, for axes
latlim = sort([ceil(max(vlat(:))),floor(min(vlat(:)))]);
lonlim = sort([ceil(max(vlon(:))),floor(min(vlon(:)))]);

% set the map axes
axesm('MapProjection', mproj, ...
      'MapLatLimit', latlim, 'MapLonLimit', lonlim);

% project geolocated data grid onto map axes
surfm(vlat, vlon, vc)

% add a grid and title
mlabel on
plabel on
gridm on
title('test map')

% add coastlines
ctmp = load('coast');
plotm(ctmp.lat, ctmp.long, 'y');

zoom on

% save the plot as a .fig file
% saveas(gcf, sprintf('%s_%s.fig', vstr, vmsc.rgbstr))

%----------------
% raw image dump
%----------------

figure (2)
imagesc(vc)
title([rid(2:9), ' ', rid(12:17), ' real'])
xlabel('cross track FOV')
ylabel('along track FOV')
colorbar

geo.Asc_Desc_Flag(floor(nscan/2))

pause

end

%--------------------
% lat/lon validation
%--------------------

lat = img_lat;
lon = img_lon;

figure(1); clf
k = floor(3*nscan/2);
aind = k:k+3;
plot(1:90, lat(:, aind))
title('x-track lat')
xlabel('x-track index')
ylabel('latitude')
legend('scan 1', 'scan 2', 'scan 3', 'scan 4', 'location', 'best')
zoom on

figure(2); clf
plot(1:90, lon(:, aind))
title('x-track lon')
xlabel('x-track index')
ylabel('longitude')
legend('scan 1', 'scan 2', 'scan 3', 'scan 4', 'location', 'best')
zoom on

figure(3); clf
xind = 43:46;
plot(1:3*nscan, lat(xind,:))
title('a-track lat')
xlabel('a-track index')
ylabel('latitude')
legend('track 1', 'track 2', 'track 3', 'track 4', 'location', 'best')
zoom on

figure(4); clf
plot(1:3*nscan, lon(xind,:))
title('a-track lon')
xlabel('a-track index')
ylabel('longitude')
legend('track 1', 'track 2', 'track 3', 'track 4', 'location', 'best')
zoom on

