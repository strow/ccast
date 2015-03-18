
addpath ./utils
addpath /asl/matlib/fileexchange/export_fig

% 1. LW residuals vs FOV 5, [650, 1095] 1/cm
a = [
1.20  0.0628  0.0557  0.0530  0.0475  0.0000  0.0539  0.0669  0.0508  0.0700
1.15  0.0620  0.0556  0.0525  0.0466  0.0000  0.0535  0.0668  0.0507  0.0657
1.10  0.0614  0.0557  0.0521  0.0462  0.0000  0.0532  0.0668  0.0507  0.0623
1.05  0.0610  0.0557  0.0518  0.0465  0.0000  0.0530  0.0670  0.0508  0.0598
1.00  0.0610  0.0557  0.0515  0.0473  0.0000  0.0529  0.0671  0.0511  0.0585
0.95  0.0612  0.0558  0.0513  0.0487  0.0000  0.0528  0.0674  0.0515  0.0585
0.90  0.0617  0.0559  0.0512  0.0507  0.0000  0.0529  0.0678  0.0520  0.0598
0.85  0.0625  0.0560  0.0512  0.0532  0.0000  0.0531  0.0682  0.0527  0.0624
0.80  0.0635  0.0561  0.0512  0.0562  0.0000  0.0533  0.0687  0.0535  0.0663
0.75  0.0648  0.0563  0.0513  0.0596  0.0000  0.0537  0.0693  0.0544  0.0711
0.70  0.0664  0.0565  0.0515  0.0633  0.0000  0.0542  0.0700  0.0554  0.0769
];
[mx, ix] = min(a); b = a(ix,1);
fprintf(1, 'test 1 residals by FOV\n')
fprintf(1, '%8.4f', b(2:end)), fprintf(1, '\n')

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a(:,1), a(:, 2:end), 'linewidth', 2)
title('LW residuals vs FOV 5, 650 to 1095 1/cm')
axis([a(end,1), a(1,1), 0.04, 0.07])
legend(fovnames, 'location', 'eastoutside')
xlabel('a2 scaling factor')
ylabel('residual')
grid on; zoom on
saveas(gcf, 'test_1.png', 'png')

% 2. LW residuals vs FOV 5, [660, 1085] 1/cm
a = [
1.20  0.0583  0.0522  0.0479  0.0442  0.0000  0.0495  0.0636  0.0472  0.0665
1.15  0.0574  0.0522  0.0475  0.0433  0.0000  0.0492  0.0635  0.0471  0.0621
1.10  0.0569  0.0522  0.0472  0.0430  0.0000  0.0489  0.0635  0.0471  0.0585
1.05  0.0565  0.0523  0.0469  0.0432  0.0000  0.0488  0.0636  0.0472  0.0559
1.00  0.0565  0.0523  0.0467  0.0440  0.0000  0.0487  0.0638  0.0474  0.0543
0.95  0.0567  0.0524  0.0466  0.0454  0.0000  0.0488  0.0640  0.0478  0.0541
0.90  0.0572  0.0526  0.0466  0.0474  0.0000  0.0489  0.0644  0.0483  0.0551
0.85  0.0580  0.0527  0.0466  0.0498  0.0000  0.0491  0.0648  0.0489  0.0575
0.80  0.0590  0.0529  0.0467  0.0527  0.0000  0.0495  0.0653  0.0497  0.0611
0.75  0.0604  0.0531  0.0469  0.0560  0.0000  0.0499  0.0659  0.0505  0.0657
0.70  0.0620  0.0533  0.0472  0.0597  0.0000  0.0504  0.0665  0.0515  0.0712
];
[mx, ix] = min(a); b = a(ix,1);
fprintf(1, 'test 2 residals by FOV\n')
fprintf(1, '%8.4f', b(2:end)), fprintf(1, '\n')

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a(:,1), a(:, 2:end), 'linewidth', 2)
title('LW residuals vs FOV 5, 660 to 1085 1/cm')
axis([a(end,1), a(1,1), 0.04, 0.07])
legend(fovnames, 'location', 'eastoutside')
xlabel('a2 scaling factor')
ylabel('residual')
grid on; zoom on
saveas(gcf, 'test_2.png', 'png')

% 3. LW residuals vs FOV 5, [672, 705] 1/cm
a = [
1.20  0.0611  0.0477  0.0550  0.0470  0.0000  0.0534  0.0412  0.0429  0.0872
1.15  0.0551  0.0467  0.0516  0.0416  0.0000  0.0501  0.0402  0.0416  0.0716
1.10  0.0503  0.0458  0.0484  0.0389  0.0000  0.0472  0.0402  0.0411  0.0578
1.05  0.0472  0.0450  0.0455  0.0396  0.0000  0.0448  0.0410  0.0414  0.0475
1.00  0.0460  0.0444  0.0430  0.0435  0.0000  0.0428  0.0426  0.0425  0.0436
0.95  0.0469  0.0440  0.0409  0.0501  0.0000  0.0414  0.0450  0.0445  0.0479
0.90  0.0500  0.0437  0.0394  0.0585  0.0000  0.0407  0.0481  0.0472  0.0589
0.85  0.0549  0.0437  0.0386  0.0681  0.0000  0.0407  0.0517  0.0505  0.0738
0.80  0.0611  0.0438  0.0384  0.0784  0.0000  0.0415  0.0558  0.0544  0.0909
0.75  0.0684  0.0441  0.0389  0.0894  0.0000  0.0430  0.0602  0.0587  0.1093
0.70  0.0765  0.0446  0.0402  0.1008  0.0000  0.0451  0.0650  0.0633  0.1285
];
[mx, ix] = min(a); b = a(ix,1);
fprintf(1, 'test 3 residals by FOV\n')
fprintf(1, '%8.4f', b(2:end)), fprintf(1, '\n')

figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a(:,1), a(:, 2:end), 'linewidth', 2)
title('LW residuals vs FOV 5, 672 to 705 1/cm')
axis([a(end,1), a(1,1), 0.03, 0.09])
legend(fovnames, 'location', 'eastoutside')
xlabel('a2 scaling factor')
ylabel('residual')
grid on; zoom on
saveas(gcf, 'test_3.png', 'png')

% 4. MW residuals vs FOV 5, [1210, 1750] 1/cm
a = [
1.20  0.0432  0.0422  0.0531  0.0405  0.0000  0.0484  0.1913  0.0659  0.0743
1.15  0.0432  0.0405  0.0510  0.0403  0.0000  0.0452  0.1554  0.0546  0.0700
1.10  0.0435  0.0394  0.0504  0.0402  0.0000  0.0424  0.1202  0.0455  0.0660
1.05  0.0441  0.0387  0.0514  0.0401  0.0000  0.0400  0.0876  0.0405  0.0621
1.00  0.0450  0.0386  0.0539  0.0401  0.0000  0.0380  0.0624  0.0411  0.0585
0.95  0.0463  0.0390  0.0577  0.0400  0.0000  0.0366  0.0569  0.0472  0.0553
0.90  0.0478  0.0400  0.0627  0.0400  0.0000  0.0359  0.0762  0.0573  0.0524
0.85  0.0496  0.0415  0.0686  0.0400  0.0000  0.0358  0.1084  0.0696  0.0499
0.80  0.0516  0.0434  0.0751  0.0400  0.0000  0.0364  0.1455  0.0833  0.0480
0.75  0.0538  0.0458  0.0823  0.0401  0.0000  0.0377  0.1850  0.0978  0.0466
0.70  0.0563  0.0485  0.0898  0.0401  0.0000  0.0395  0.2259  0.1129  0.0459
];
[mx, ix] = min(a); b = a(ix,1);
fprintf(1, 'test 4 residals by FOV\n')
fprintf(1, '%8.4f', b(2:end)), fprintf(1, '\n')

figure(4); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a(:,1), a(:, 2:end), 'linewidth', 2)
title('MW residuals vs FOV 5, 1210 to 1750 1/cm')
axis([a(end,1), a(1,1), 0.01, 0.09])
legend(fovnames, 'location', 'eastoutside')
xlabel('a2 scaling factor')
ylabel('residual')
grid on; zoom on
saveas(gcf, 'test_4.png', 'png')

% 5. MW residuals vs FOV 6, [1210, 1750] 1/cm
a = [
1.20  0.0408  0.0564  0.0657  0.0526  0.0484  0.0000  0.2229  0.0890  0.0357
1.15  0.0399  0.0487  0.0568  0.0484  0.0452  0.0000  0.1817  0.0695  0.0353
1.10  0.0390  0.0416  0.0500  0.0442  0.0424  0.0000  0.1410  0.0503  0.0349
1.05  0.0381  0.0355  0.0463  0.0403  0.0400  0.0000  0.1020  0.0321  0.0344
1.00  0.0372  0.0310  0.0465  0.0365  0.0380  0.0000  0.0684  0.0191  0.0340
0.95  0.0363  0.0290  0.0507  0.0329  0.0366  0.0000  0.0534  0.0232  0.0336
0.90  0.0355  0.0300  0.0580  0.0298  0.0359  0.0000  0.0712  0.0395  0.0332
0.85  0.0347  0.0338  0.0674  0.0271  0.0358  0.0000  0.1071  0.0589  0.0328
0.80  0.0339  0.0395  0.0782  0.0251  0.0364  0.0000  0.1490  0.0791  0.0325
0.75  0.0331  0.0465  0.0899  0.0238  0.0377  0.0000  0.1933  0.0997  0.0321
0.70  0.0323  0.0543  0.1023  0.0236  0.0395  0.0000  0.2392  0.1207  0.0317
];
[mx, ix] = min(a); b = a(ix,1);
fprintf(1, 'test 5 residals by FOV\n')
fprintf(1, '%8.4f', b(2:end)), fprintf(1, '\n')

figure(5); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a(:,1), a(:, 2:end), 'linewidth', 2)
title('MW residuals vs FOV 6, 1210 to 1750 1/cm')
axis([a(end,1), a(1,1), 0.01, 0.09])
legend(fovnames, 'location', 'eastoutside')
xlabel('a2 scaling factor')
ylabel('residual')
grid on; zoom on
saveas(gcf, 'test_5.png', 'png')

% 6. MW residuals vs FOV 9, [1210, 1750] 1/cm
a = [
1.20  0.0628  0.0843  0.0864  0.0808  0.0743  0.0357  0.2481  0.1169  0.0000
1.15  0.0612  0.0757  0.0747  0.0759  0.0700  0.0353  0.2059  0.0968  0.0000
1.10  0.0595  0.0674  0.0640  0.0712  0.0660  0.0349  0.1638  0.0770  0.0000
1.05  0.0579  0.0595  0.0548  0.0665  0.0621  0.0344  0.1224  0.0577  0.0000
1.00  0.0563  0.0523  0.0483  0.0619  0.0585  0.0340  0.0835  0.0400  0.0000
0.95  0.0547  0.0462  0.0454  0.0574  0.0553  0.0336  0.0542  0.0275  0.0000
0.90  0.0531  0.0415  0.0470  0.0532  0.0524  0.0332  0.0550  0.0284  0.0000
0.85  0.0515  0.0390  0.0527  0.0491  0.0499  0.0328  0.0858  0.0421  0.0000
0.80  0.0500  0.0390  0.0614  0.0453  0.0480  0.0325  0.1269  0.0606  0.0000
0.75  0.0484  0.0415  0.0720  0.0418  0.0466  0.0321  0.1715  0.0807  0.0000
0.70  0.0468  0.0461  0.0839  0.0388  0.0459  0.0317  0.2178  0.1016  0.0000
];
[mx, ix] = min(a); b = a(ix,1);
fprintf(1, 'test 6 residals by FOV\n')
fprintf(1, '%8.4f', b(2:end)), fprintf(1, '\n')

figure(6); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a(:,1), a(:, 2:end), 'linewidth', 2)
title('MW residuals vs FOV 9, 1210 to 1750 1/cm')
axis([a(end,1), a(1,1), 0.01, 0.09])
legend(fovnames, 'location', 'eastoutside')
xlabel('a2 scaling factor')
ylabel('residual')
grid on; zoom on
saveas(gcf, 'test_6.png', 'png')
