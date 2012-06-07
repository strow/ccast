%
% sftab1 -- tabulate non-zero scan flags
%
% output is an array sftab with columns [time, flags, FOV, band],
% sorted in time order

% matlab RDR data directory
% rdir = '/asl/data/cris/rdr_proxy/mat/2010/249';
rdir = '/asl/data/cris/rdr60/mat/2012/024x';

flist = dir(sprintf('%s/RDR*.mat', rdir));
nfile = length(flist);

% scan flags table
sftab = [];

% ---------------------
% loop on RDR mat files
% ---------------------

for fi = 1 : nfile

  % matlab RDR data file
  rid = flist(fi).name(5:22);
  rtmp = ['RDR_', rid, '.mat'];
  rfile = [rdir, '/', rtmp];

  % skip processing if no matlab RDR file
  if ~exist(rfile, 'file')
    fprintf(1, 'RDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the RDR data, defines structures d1 and m1
  load(rfile)

  % save LW flags
  iLW = find(d1.packet.LWES.ssflags > 0);
  if ~isempty(iLW)
    [i1, i2] = ind2sub(size(d1.packet.LWES.ssflags), iLW);
    for i = 1 : length(i1)

      rtmp = [d1.packet.LWES.time(i1(i), i2(i)), ...
              d1.packet.LWES.ssflags(i1(i), i2(i)), ...
              1, i2(i)];
 
      sftab = [sftab; rtmp];
    end
  end

  % save MW flags
  iMW = find(d1.packet.MWES.ssflags > 0);
  if ~isempty(iMW)
    [i1, i2] = ind2sub(size(d1.packet.MWES.ssflags), iMW);
    for i = 1 : length(i1)

      rtmp = [d1.packet.MWES.time(i1(i), i2(i)), ...
              d1.packet.MWES.ssflags(i1(i), i2(i)), ...
              2, i2(i)];

      sftab = [sftab; rtmp];
    end
  end

  % save SW flags
  iSW = find(d1.packet.SWES.ssflags > 0);
  if ~isempty(iSW)
    [i1, i2] = ind2sub(size(d1.packet.SWES.ssflags), iSW);
    for i = 1 : length(i1)

      rtmp = [d1.packet.SWES.time(i1(i), i2(i)), ...
              d1.packet.SWES.ssflags(i1(i), i2(i)), ...
              3, i2(i)];

      sftab = [sftab; rtmp];
    end
  end

% for i = 1 : length(iLW)
%   [nchan, j, k] = size(d1.idata.LWES);
%   igm = reshape(d1.idata.LWES, nchan, j * k);
%   plot(real(igm(:, iLW(i))));
%   d1.packet.LWES.ssflags(iLW(i))
%   pause
% end
%
% for i = 1 : length(iSW)
%   [nchan, j, k] = size(d1.idata.SWES);
%   igm = reshape(d1.idata.SWES, nchan, j * k);
%   plot(real(igm(:, iSW(i))));
%   d1.packet.SWES.ssflags(iLW(i))
%   pause
% end

end

% sort the table
[tmp, ix] = sort(sftab(:, 1));
sftab = sftab(ix, :, :, :);

save sftab sftab

