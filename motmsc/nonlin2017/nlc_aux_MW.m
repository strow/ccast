%
% nlc_aux;  run from inside calmain_a4
%

  calfnx = load('gainfnxMW');
% calfnx = load('gainfnxLW');

r1 = specES_SP;
r2 =  nlc_new(inst, rcnt(:, :, iES, si), avgSP(:, :, j, si), eng) ...
   -  nlc_new(inst, avgSP(:, :, j, si),  avgSP(:, :, j, si), eng);
r3 = nlc_poly(inst, rcnt(:, :, iES, si), avgSP(:, :, j, si), eng, calfnx);   

figure(1); clf
fi = 9;
xx = inst.freq;
subplot(2,1,1)
plot(xx, abs(r1(:, fi)), xx, abs(r2(:, fi)), xx, abs(r3(:, fi)))
axis([1100, 1800, 0, 0.5])
title(sprintf('NLC correction test, FOV %d', fi))
legend('raw ES-SP', 'ATBD NLC', 'poly NLC', 'location', 'northeast')
ylabel('volts')
grid on; zoom on

subplot(2,1,2)
fi = 7;
plot(xx, abs(r1(:, fi)), xx, abs(r2(:, fi)), xx, abs(r3(:, fi)))
axis([1100, 1800, 0, 0.5])
title(sprintf('NLC correction test, FOV %d', fi))
legend('raw ES-SP', 'ATBD NLC', 'poly NLC', 'location', 'northeast')
xlabel('wavenumber')
ylabel('volts')
grid on; zoom on

