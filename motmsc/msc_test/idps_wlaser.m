%
% plot (and save) IPDS SDR wlaser values for multiple days
%
% run from ccast/motmsc
%

addpath asl
addpath utils
addpath ../source

% path to day-of-year directories
ydir = '/asl/data/cris/sdr60/hdf/2013/';

% start and end day-of-year
d1 = 191;  % start of new fields
d1 = 305;
d2 = 346;

%-----------------
% gather the data
%-----------------

% initialize output
measured = [];
resample = [];
scantime = [];

% loop on days
for di = d1 : d2

  doy = sprintf('%03d', di);
  sdir = fullfile(ydir, doy);
  slist = dir(fullfile(sdir, 'SCRIS_npp_*.h5'));

  % loop on files
  for si = 1 : length(slist)

    % get SDR file
    sid = slist(si).name(11:28);
    sfile = fullfile(sdir, slist(si).name);
    try
      pd = readsdr_fast(sfile);
    catch
      continue
    end

    % get corresponding geo file
    glist = dir(fullfile(sdir, ['GCRSO_npp_', sid, '*_noaa_ops.h5']));
    if isempty(glist)
      continue
    end
    gtmp = glist(end).name;
    gfile = fullfile(sdir, gtmp);
    try
      geo = read_GCRSO(gfile);  
    catch
      continue
    end
 
    measured = [measured; pd.MeasuredLaserWavelength];
    resample = [resample; pd.ResamplingLaserWavelength];
    scantime = [scantime; geo.StartTime];
  
  end
  fprintf(1, '.')
end
fprintf(1, '\n')

% clean up obs
iok = find(~isnan(measured) & measured > 0 & ...
           ~isnan(resample) & resample > 0 & ...
           ~isnan(scantime) & scantime > 0);

measured = measured(iok);
resample = resample(iok);
scantime = scantime(iok);
scantime = double(scantime);

% return half-wavelengths
measured = measured / 2;

% save the data
fstr = sprintf('idps_wlaser_%d_%d', d1, d2);
save(fstr, 'measured', 'resample', 'scantime')

%------------------
% plot the results
%------------------

figure(3); clf
x = iet2mat(scantime);
plot(x, measured, x, resample)
ax = axis; ax(3) = 773.1285; ax(4) = 773.1315; axis(ax)
datetick('x', 6)
legend('measured', 'resampling', 'location', 'best')
title('IDPS metrology laser')
ylabel('laser half-wavelength')
xlabel('date')
grid on; zoom on
saveas(gcf, fstr, 'fig')

