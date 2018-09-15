%
% NAME
%   cmp_means -- compare mean and std over over several days
%

% function cmp_means(year, dlist, ydir1, ydir2, mfile)

year = 2018;
% dlist = 60:75;
  dlist = 76:91;
ydir1 = '/asl/data/cris/ccast/sdr45_j01_HR/2018';
ydir2 = '/asl/data/cris/ccast/sdr45_j1v4_HR/2018';
mfile = 'cmp_means';

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% initialize recursive variance
nchan = 637;
n1 = zeros(9,1);
m1 = zeros(nchan, 9);
w1 = zeros(nchan, 9);

% loop on days of the year
for doy = dlist;
  
  % loop on CrIS granules
  dstr = sprintf('%03d', doy);
  fprintf(1, 'doy %s ', dstr)
  flist1 = dir(fullfile(ydir1, dstr, 'CrIS_SDR*.mat'));
  flist2 = dir(fullfile(ydir2, dstr, 'CrIS_SDR*.mat'));

  for fi = 1 : length(flist1);
    cgran1 = fullfile(ydir1, dstr, flist1(fi).name);
    cgran2 = fullfile(ydir2, dstr, flist2(fi).name);

    % load SW radiances
    d1 = load(cgran1, 'vSW', 'rSW', 'L1b_err', 'geo');
    d2 = load(cgran2, 'rSW');
    rad1 = d1.rSW;
    rad2 = d2.rSW;
    lat = d1.geo.Latitude;
    lon = d1.geo.Longitude;
    fov = repmat((1:9)', 1, 30, 45);
    vSW = d1.vSW;

    % valid subset
    iOK = ~d1.L1b_err;
    rad1 = rad1(:,iOK);
    rad2 = rad2(:,iOK);
    lat = lat(iOK);
    lon = lon(iOK);
    fov = fov(iOK);

    % latitude subset
    lat_rad = deg2rad(lat);
    [m,n] = size(lat_rad);
    jx = rand(m, n) < abs(cos(lat_rad));
    rad1 = rad1(:,jx);
    rad2 = rad2(:,jx);
    lat = lat(jx);
    lon = lon(jx);
    fov = fov(jx);

    % brightness temps
    bt1 = real(rad2bt(vSW, rad1));
    bt2 = real(rad2bt(vSW, rad2));

    % mean and variance by FOV
    for i = 1 : 9
      ix = find(fov == i);
      for j = 1 : length(ix)
        dbt = bt2(:, ix(j)) - bt1(:, ix(j));
        [m1(:,i), w1(:,i), n1(i)] = rec_var(m1(:,i), w1(:,i), n1(i), dbt);
      end
    end
    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

dbt_mean = m1;
dbt_var = w1 ./ (n1' - 1);
dbt_std = sqrt(dbt_var);

save(mfile, 'year', 'dlist', 'ydir1', 'ydir2', 'vSW', ...
            'dbt_mean', 'dbt_var', 'dbt_std', 'n1')

figure(1)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vSW, dbt_mean)
title('set 2 minus set 1 mean')
axis([2150, 2550, -0.15, 0.15])
legend(fovnames, 'location', 'northeast')
grid on

subplot(2,1,2)
plot(vSW, dbt_std)
title('set 2 minus set 1 std')
axis([2150, 2550, 0, 0.3])
% legend(fovnames, 'location', 'northeast')
grid on

