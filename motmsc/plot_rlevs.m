%
% plot_rlevs -- plot radiance level means from match_a5
%

addpath utils
addpath ../source

d1 = load('match_a5');       % uncal_a5 and h3a2new
d2 = load('match_no_nlc');   % uncal_a5 and no_nlc_e7
d3 = load('match_olda2');    % uncal_a5 and sdr60_hr
d4 = load('match_newUWa2');  % uncal_a5 and newUWMWa2

r1LW = mean(d1.radmeanLW, 2);
r1MW = mean(d1.radmeanMW, 2);
r2LW = mean(d2.radmeanLW, 2);
r2MW = mean(d2.radmeanMW, 2);
r3LW = mean(d3.radmeanLW, 2);
r3MW = mean(d3.radmeanMW, 2);
r4LW = mean(d4.radmeanLW, 2);
r4MW = mean(d4.radmeanMW, 2);

% current default a2 values (from eng and inst params)
UWoldLW = [0.0194 0.0143 0.0161 0.0219 0.0134 0.0164 0.0146 0.0173 0.0305]';
UWoldMW = [0.0053 0.0216 0.0292 0.0121 0.0143 0.0037 0.1070 0.0456 0.0026]';

% 2016 UW values via Yong Chen
UWnewMW = [0.0033 0.0178 0.0271 0.0073 0.0104 0.0024 0.0936 0.0434 0.0026]';

% 2016 UMBC values
umbcLW = [0.0175 0.0122 0.0137 0.0219 0.0114 0.0164 0.0124 0.0164 0.0305]';
umbcMW = [0.0016 0.0173 0.0263 0.0079 0.0093 0.0015 0.0963 0.0410 0.0016]';

% algo comparison
figure(1);
minLW = min([r1LW; r2LW; r3LW]);
bar([r2LW - minLW, r1LW - minLW, r3LW - minLW])
title('LW radiance means by FOV')
legend('uncorrected', 'new UMBC', 'old UW', 'location', 'northwest');
xlabel('FOV')
ylabel('rad - min(rad)')
grid on

figure(2);
minMW = min([r1MW; r2MW; r3MW; r4MW]);
bar([r2MW - minMW, r1MW - minMW, r4MW - minMW, r3MW - minMW])
title('MW radiance means by FOV')
legend('uncorrected', 'new UMBC', 'new UW', 'old UW', 'location', 'northwest');
xlabel('FOV')
ylabel('rad - min(rad)')
grid on

% uncorr vs a2 values
figure(3)
minLW = min([r1LW; r2LW]);
maxLW = max([r1LW; r2LW]);
a2wLW = (maxLW - minLW) / ((max(umbcLW) + max(UWoldLW)) / 2);
bar([r1LW - minLW, r2LW - minLW, UWoldLW * a2wLW, umbcLW * a2wLW])
title('LW radiance means by FOV')
legend('corrected', 'uncorrected', 'UW old scaled a2', 'UMBC scaled a2', ...
       'location', 'northwest');
xlabel('FOV')
ylabel('rad - min(rad)')
grid on

figure(4); clf
minMW = min([r1MW; r2MW]);
maxMW = max([r1MW; r2MW]);
a2wMW = (maxMW - minMW) / ((max(umbcMW) + max(UWoldMW)) / 2);
bar([r1MW - minMW, r2MW - minMW, UWoldMW * a2wMW, umbcMW * a2wMW])
title('MW radiance means by FOV')
legend('corrected', 'uncorrected', 'UW old scaled a2', 'UMBC scaled a2', ...
       'location', 'northwest');
xlabel('FOV')
ylabel('rad - min(rad)')
grid on

