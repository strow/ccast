%
% plot_a2fun  - plot MW a2 functions
%

addpath utils
addpath ../source

band = 'MW';
load eng_typical
load match_no_nlc

opt1 = struct;
opt1.user_res = 'hires';
opt1.inst_res = 'hires3';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

% get the spectral space numeric filter
opt1.NF_file = '../inst_data/FIR_19_Mar_2012.txt';
inst.sNF = specNF(inst, opt1.NF_file);

% band params
switch upper(band)
  case 'LW'
    bi = 1;  
    UW_NF_scale = 1.6047;
    Vlev = mean(ESvlevLW, 2);
    r1 = mean(radmeanLW, 2);
  case 'MW', 
    bi = 2;  
    UW_NF_scale = 0.9826;
    Vlev = mean(ESvlevMW, 2);
    r1 = mean(radmeanMW, 2);
  otherwise, error('bad band spec');
end

% rescale data from old match_a5 run
Vlev = Vlev * 2 / inst.df;

% get params from eng
cm = eng.Modulation_eff.Band(bi).Eff;
cp = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
Vinst = eng.Linearity_Param.Band(bi).Vinst;

% put eng params in column order
cm = cm(:); cp = cp(:); Vinst = Vinst(:);

% analog to digital gain
ca = 8192/2.5;

% combined gain factor
cg = cm .* cp * ca * inst.df / 2;

% UW scaling factor
UW_fudge = (max(inst.sNF)/UW_NF_scale);

% get the DC level
Vdc = Vinst + UW_fudge * Vlev;

% 2016 UMBC values
umbcLW = [0.0175 0.0122 0.0137 0.0219 0.0114 0.0164 0.0124 0.0164 0.0305]';
umbcMW = [0.0016 0.0173 0.0263 0.0079 0.0093 0.0015 0.0963 0.0410 0.0016]';

% plot correction functions
rx1 = (0 : 0.01 : 0.2)';
nx1 = length(rx1);
rx2 = zeros(nx1, 9);
ry2 = zeros(nx1, 9);

% regular UW nonlin function
for i = 1 : 9
  rx2(:, i) = rx1 .* (1 + 2 * umbcMW(i) .* (Vinst(i) + UW_fudge .* rx1));
% rx2(:, i) = rx1 .* (1 + 2 * umbcMW(i) .* (Vinst(i) + rx1));
end

% nonlin function with r^2 term
for i = 1 : 9
  ry2(:, i) = rx1 .* (1 + 2 * umbcMW(i) .* (Vinst(i) + UW_fudge .* rx1)) ...
            + umbcMW(i) .* rx1 .* rx1;
end

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(rx1, rx2, 'linewidth', 2)
title('MW nonlin corrections')
legend(fovnames, 'location', 'northwest')
xlabel('Volts')
ylabel('Volts')
grid on;
% saveas(gcf, 'MW_nonlin_corr', 'png')

% single FOV with level integral steps
i = 7;
dclev = 0.05 : 0.05 : 0.20
nlev = length(dclev);
rz2 = zeros(nx1, nlev);

for j = 1 : nlev
  rz2(:, j) = rx1 .* (1 + 2 * umbcMW(i) .* (Vinst(i) + UW_fudge .* dclev(j)));
end

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(rx1, rz2, 'linewidth', 2)
title(sprintf('MW FOV %d correction with Vlev steps', i))
legend('0.05', '0.10', '0.15', '0.20', 'location', 'northwest')
xlabel('Volts')
ylabel('Volts')
grid on;
% saveas(gcf, 'MW_FOV_7_corr', 'png')

