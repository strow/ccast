%
% cold_cfovs - scan ccast SDR files for cold obs
%
% edit the test section inside the loops for other apps
%
% works for both regular and high res data, but opt.resmode 
% must match the test data specified byt syear and sdays.

addpath ./utils
addpath ../source

% test parameters
band = 'SW';
sFOR = 15:16;   % fields of regard (1-30)
adflag = 1;     % ascending/descending flag

% path to SDR year
% syear = '/asl/data/cris/ccast/sdr60/2013';
% syear = '/asl/data/cris/ccast/sdr60_p/2013';
% syear = '/asl/data/cris/ccast/sdr60_hr/2013';
  syear = '/asl/data/cris/ccast/sdr60_hr_p/2013';

% SDR days of the year
% sdays = 71;         % high res test 1
  sdays = 239 : 240;  % high res test 2
% sdays = 238;
% sdays = 64 : 77;
% sdays = 60 : 62;

% get user grid 
opts = struct;
opts.resmode = 'hires2';
[inst, user] = inst_params(band, 773.13, opts);
nchan = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 + (0:nchan-1)' * user.dv;
hamm = mkhamm(nchan);

% initialize output
cobs = struct;
iobs = 0;

% loop on days
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    % get data and frequency grid for this band
    switch(band)
      case 'LW', rtmp = rLW; vtmp = vLW(:);
      case 'MW', rtmp = rMW; vtmp = vMW(:);
      case 'SW', rtmp = rSW; vtmp = vSW(:);
    end

    % get data at the user grid
    [m, n, k, nscan] = size(rtmp);
    [ix, jx] = seq_match(vgrid, vtmp);
    if ~isclose(vgrid, vtmp(jx))
      error('frequency grid mismatch')
    end

    % loop on scans
    for iscan = 1 : nscan
      if geo.Asc_Desc_Flag(iscan) ~= adflag
        continue
      end

      % loop on FORs
      for iFOR = sFOR

        % loop on FOVs
        for iFOV = 1 : 9
          r1 = rtmp(jx, iFOV, iFOR, iscan);

          % get apodized radiances
          r2 = hamm * r1;
          b2 = real(rad2bt(vgrid, r2));

          % test apodized brightness tmpes
          if ~isempty(find(mean(b2) < 210))
%         if ~isempty(find(b2 < 200))

            % save selected unapodized obs
            iobs = iobs + 1;
            cobs(iobs).rad  = r1;
            cobs(iobs).bt = real(rad2bt(vgrid, r1));
            cobs(iobs).vgrid = vgrid;
            cobs(iobs).FOV = iFOV;
            cobs(iobs).FOR = iFOR;
            cobs(iobs).time = geo.FORTime(iFOR, iscan);
            cobs(iobs).lat  = geo.Latitude(iFOV, iFOR, iscan);
            cobs(iobs).lon  = geo.Longitude(iFOV, iFOR, iscan);


          end   % obs test
        end     % loop on FOVs
      end       % loop on FORs
    end         % loop on scans
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

save cold_cfovs cobs band user iFOR adflag sdays syear

return

for i = 1 : iobs
  plot(cobs(i).vgrid, cobs(i).bt)
  xlabel('wavenumber')
  xlabel('brightness temp')
  grid on; zoom on
  fprintf(1, 'lat %6.2f, lon %6.2f, FOV %d, FOR %d\n',  ...
              cobs(i).lat, cobs(i).lon, cobs(i).FOV, cobs(i).FOR)
  pause
end

