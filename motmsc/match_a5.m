%
% match_a5 - match ES calibrated and uncalibrated looks
%
% uses uncalibrated data from ccast_test5/rdr2sdr_a5/calmain_a5
%
% tabulated values, 9 x nobs
%   T900_val  - 900cm-1 brightness temp
%   Tb_mean   - mean sensor grid brightness temp
%   radmean   - mean sensor grid radiance
%   ESmean    - mean(ES)
%   ESdiff    - mean(ES - SP)
%   ESvlev    - mean(abs(ES - SP))
%   scan_tab  - nobs x 1 scan index (1-60)
%   for_tab   - nobs x 1 FOR (1-30)
%   rid_tab   - nobs x 18 char array
%

addpath ../source
addpath ../motmsc/utils
addpath ../motmsc/fov5_anom

%-----------------
% test parameters
%-----------------
sFOR = 15:16;  % fields of regard, 1-30

% path to SDR year
  tstr1 = 'h3a2new';
% tstr1 = 'newUWMWa2';
% tstr1 = 'sdr60_hr';
% tstr2 = 'uwnlc_a5';
  tstr2 = 'uncal_a5';

syear1 = fullfile('/asl/data/cris/ccast', tstr1, '2016');
syear2 = fullfile('/asl/data/cris/ccast', tstr2, '2016');

% SDR days of the year
  sdays =  18 : 20;
% sdays = 20;

% initialize outputs
n = length(sdays) * 181 * 61 * length(sFOR);
T900_val = zeros(9, n);
Tb_meanLW = zeros(9, n);
Tb_meanMW = zeros(9, n);
radmeanLW = zeros(9, n);
radmeanMW = zeros(9, n);
ESmeanLW = zeros(9, n);
ESmeanMW = zeros(9, n);
ESdiffLW = zeros(9, n);
ESdiffMW = zeros(9, n);
ESvlevLW = zeros(9, n);
ESvlevMW = zeros(9, n);
scan_tab = zeros(n, 1);
for_tab = zeros(n, 1);
rid_tab = [];

%------------------------
% loop on days and files
%------------------------
k = 0;
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist1 = dir(fullfile(syear1, doy, 'SDR*.mat'));
  flist2 = dir(fullfile(syear2, doy, 'SDR*.mat'));

  for fi = 1 : length(flist1);

    % load the SDR data
    rid = flist1(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile1 = fullfile(syear1, doy, stmp);
    sfile2 = fullfile(syear2, doy, stmp);
    d1 = load(sfile1);
    d2 = load(sfile2);

    % loop on scans
    [t1, t2, t3, nscan] = size(d1.rLW);
    for j = 1 : nscan

      % loop on selected FORs
      for i = sFOR
        if d1.L1a_err(i, j)
          continue
        end
        if ~isempty(find(isnan(d1.rLW(:, :, i, j))))
          continue
        end
        if ~isempty(find(d1.rLW(:, :, i, j) <= 0))
          continue
        end        

        % calibrated brightness temps
        Tb_LW = real(rad2bt(d1.vLW, d1.rLW(:, :, i, j)));
        Tb_MW = real(rad2bt(d1.vMW, d1.rMW(:, :, i, j)));

        % save selected values
        k = k + 1;
        T900_val(:, k) = Tb_LW(403, :)';
        Tb_meanLW(:, k) = mean(Tb_LW)';
        Tb_meanMW(:, k) = mean(Tb_MW)';
        radmeanLW(:, k) = mean(d1.rLW(:, :, i, j))';
        radmeanMW(:, k) = mean(d1.rMW(:, :, i, j))';
        ESmeanLW(:, k) = mean(d2.ESLW(:,:,i,j))';
        ESmeanMW(:, k) = mean(d2.ESMW(:,:,i,j))';
        i2 = mod(i, 2) + 1;  % SP and IT index parity flip
        ESdiffLW(:, k) = mean(d2.ESLW(:,:,i,j) - d2.SPLW(:,:,i2,j));
        ESdiffMW(:, k) = mean(d2.ESMW(:,:,i,j) - d2.SPMW(:,:,i2,j));
        ESvlevLW(:, k) = mean(abs(d2.ESLW(:,:,i,j) - d2.SPLW(:,:,i2,j)));
        ESvlevMW(:, k) = mean(abs(d2.ESMW(:,:,i,j) - d2.SPMW(:,:,i2,j)));
        scan_tab(k) = j;
        for_tab(k) =  i;
        rid_tab = [rid_tab; rid];

      end % loop on selected FORs
    end % loop on scans

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

% trim and save data
T900_val = T900_val(:, 1:k);
Tb_meanLW = Tb_meanLW(:, 1:k);
Tb_meanMW = Tb_meanMW(:, 1:k);
radmeanLW = radmeanLW(:, 1:k);
radmeanMW = radmeanMW(:, 1:k); 
ESmeanLW = ESmeanLW(:, 1:k);
ESmeanMW = ESmeanMW(:, 1:k);
ESdiffLW = ESdiffLW(:, 1:k);
ESdiffMW = ESdiffMW(:, 1:k);
ESvlevLW = ESvlevLW(:, 1:k);
ESvlevMW = ESvlevMW(:, 1:k);
scan_tab = scan_tab(1:k);
for_tab = for_tab(1:k);

vLW = d1.vLW;
vMW = d1.vMW;

save match_a5 vLW T900_val Tb_meanLW Tb_meanMW ...
     radmeanLW radmeanMW ESmeanLW ESmeanMW ESdiffLW ESdiffMW ...
     ESvlevLW ESvlevMW scan_tab for_tab rid_tab

% save match_newUWa2 vLW T900_val Tb_meanLW Tb_meanMW ...
%      radmeanLW radmeanMW ESmeanLW ESmeanMW ESdiffLW ESdiffMW ...
%      ESvlevLW ESvlevMW scan_tab for_tab rid_tab

