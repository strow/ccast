
% rdr2spec5
% img_re1 = img_re;
% img_im1 = img_im;
%
% rdr2spec5        
% img_re2 = img_re;
% img_im2 = img_im;
%
% save tileplot1 img_re1 img_im1 img_re2 img_im2 

load tileplot1

img_re = scancat3(img_re1, img_re2);
img_im = scancat3(img_im1, img_im2);

figure (1)
imagesc(img_re')
title('21 Jan 2012 UTC 00:05:58.8 836.8 1/cm real cal')
xlabel('cross track FOV')
ylabel('along track FOV')
colorbar
saveas(gcf, 'd20120121_t0005588_real', 'png')

figure(2)
imagesc(img_im')
title('21 Jan 2012 UTC 00:05:58.8 836.8 1/cm imag cal')
xlabel('cross track FOV')
ylabel('along track FOV')
colorbar
saveas(gcf, 'd20120121_t0005588_imag', 'png')

