%
% demo 2d histogram
%

% function hist2d(d, x1, x2, nx, y1, y2, ny)

d = [ratTab(:, 1), ratTab(:, 4) ./ ratTab(:, 5)];

% added point for a sanity check:
d = [d;, [ones(100, 1) * 300, ones(100, 1) * 1.4]];

x1 = 190; x2 = 320; nx = 80;
y1 = 0.4; y2 = 1.6; ny = 40;

tab = zeros(nx, ny);

dx = (x2 - x1) / nx;
dy = (y2 - y1) / ny;

[m, n] = size(d);

for i = 1 : m

  x = d(i, 1);
  y = d(i, 2);

  ix = floor((x - x1) / dx) + 1;
  iy = floor((y - y1) / dy) + 1;

  if ix < 1 || nx < ix || iy < 1 || ny < iy, continue, end

  tab(ix, iy) = tab(ix, iy) + 1;

end

xaxis = x1 : dx : x2-dx;
yaxis = y1 : dy : y2-dy;

imagesc(xaxis, yaxis, log2(tab+1))
title('FOV 5 integral ratio log(bin counts)')
xlabel('900 cm-1 temp')
ylabel('integral ratio')
set(gca,'YDir','normal')
colormap(jet)
colorbar
