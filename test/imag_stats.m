%
%   imag_stats
%

year = 2018;

% dlist = 91;
  dlist = 225 : 240;
% ydir1 = '/asl/cris/ccast/sdr45_j01_HR/2018';
  ydir1 = '/asl/cris/ccast/sdr45_npp_HR/2018';

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

% initialize recursive variance
nchan = 717;
n1 = zeros(9,1);
u1 = zeros(nchan, 9);
m1 = zeros(nchan, 9);

% loop on days of the year
for doy = dlist;
  
  % loop on CrIS granules
  dstr = sprintf('%03d', doy);
  fprintf(1, 'doy %s ', dstr)
  flist1 = dir(fullfile(ydir1, dstr, 'CrIS_SDR*.mat'));

  for fi = 1 : length(flist1);
    cgran1 = fullfile(ydir1, dstr, flist1(fi).name);

    % load LW radiances
    d1 = load(cgran1, 'vLW', 'cLW', 'L1b_err', 'geo');
    cr1 = d1.cLW;
    lat = d1.geo.Latitude;
    lon = d1.geo.Longitude;
    fov = repmat((1:9)', 1, 30, 45);
    vLW = d1.vLW;

    % valid subset
    iOK = ~d1.L1b_err;
    cr1 = cr1(:,iOK);
    lat = lat(iOK);
    lon = lon(iOK);
    fov = fov(iOK);

    % latitude subset
    lat_rad = deg2rad(lat);
    [m,n] = size(lat_rad);
    jx = rand(m, n) < abs(cos(lat_rad));
    cr1 = cr1(:,jx);
    lat = lat(jx);
    lon = lon(jx);
    fov = fov(jx);

    % Hamming appodization
    cr1 = hamm_app(double(cr1));

    % mean and variance by FOV
    for i = 1 : 9
      ix = find(fov == i);
      for j = 1 : length(ix)
        cxx = cr1(:, ix(j));
        [u1(:,i), m1(:,i), n1(i)] = rec_var(u1(:,i), m1(:,i), n1(i), cxx);
      end
    end
    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

cr1_mean = u1;
cr1_var = m1 ./ (n1' - 1);
cr1_std = sqrt(cr1_var);

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vLW, cr1_mean)
axis([650, 800, -0.1, 0.15])
% title('N20 LW complex residual mean')
  title('NPP LW complex residual mean')
legend(fovnames, 'location', 'eastoutside')
ylabel('mw sr-1 m-2')
grid on

% figure(2); clf
% set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,2)
% plot(vLW, cr1_std)
  semilogy(vLW, cr1_std)
axis([650, 800, 0, 0.5])
% title('N20 LW complex residual std')
  title('NPP LW complex residual std')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber (cm-1)')
ylabel('mw sr-1 m-2')
grid on

% saveas(gcf, 'N20_imag_resid', 'png')
% saveas(gcf, 'NPP_imag_resid', 'png')

save imag_stats_npp year dlist vLW cr1_mean cr1_std

