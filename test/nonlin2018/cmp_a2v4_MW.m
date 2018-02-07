%
% compare several a2 values for the MW FOV 9 UW NPP correction
%

d1 = load('a2v4_set_1/a2v4_m20');    
d2 = load('a2v4_set_1/a2v4_m10');    
d3 = load('a2v4_set_1/a2v4_ref');    
d4 = load('a2v4_set_1/a2v4_p10');    
d5 = load('a2v4_set_1/a2v4_p20');    

vMW = d1.vMW;
bMW1 = d1.mMW;
bMW2 = d2.mMW;
bMW3 = d3.mMW;
bMW4 = d4.mMW;
bMW5 = d5.mMW;
refMW = mean(bMW3(:,1:8),2);

btmp = [bMW1(:,9),bMW2(:,9),bMW3(:,9),bMW4(:,9),bMW5(:,9)];

% --- MW comparison plot ---
figure(1); clf
plot(vMW, btmp - refMW);
s = 0.4;
axis([1200, 1760, -s, s])
title('MW FOV 9 minus ref, UW NPP algo, a2v4 weights')
legend('a2-20', 'a2-10', 'a2 ref', 'a2+10', 'a2+20', 'location', 'southwest')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

