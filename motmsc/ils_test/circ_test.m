%
% plot integration setup for CrIS FOVs

band = 'SW';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser);

ifov = 5;              % select a FOV
a  = inst.foax(ifov);  % FOV off-axis angle
r2 = inst.frad(ifov);  % FOV radius

% a = a / 1e6
a = 0;

% a = 1;    % FOV off-axis angle (test value)
% r2 = 2;   % FOV radius (test value)

n = 1000;  % FOV arc slices

b = max(0, a - r2);   % min off-axis angle  
d = a + r2 - b;       % integral angle span

% integral discrete angle steps
r1 = b : d/(n-1) : a + r2;

% x val of FOV and arc intersection
x = (a^2 + r1.^2 - r2^2) / (2*a);

% angle to FOV and arc intersection 
if a > 0
  alpha = real(acos(x ./ r1));
else
  alpha = [ones(1,n-1) * pi, 0];  % limit a -> 0
end

% integral half-arc lengths
w = alpha .* r1;

% plot internal values
figure(1); clf
subplot(3,1,1)
plot(r1, x)
title('circ test internal values')
legend('x co-ord', 'location', 'best')
grid on

subplot(3,1,2)
plot(r1, alpha)
legend('angle to intersect', 'location', 'best')
grid on; zoom on

subplot(3,1,3)
plot(r1, w)
legend('arc length', 'location', 'best')
xlabel('r1 radius')
grid on

% plot a subset of arcs
ix = 1 : floor(n/12) : n;      % subset of arcs
k = length(ix);        % arcs to plot
m = 20;                % samples per arc

% initialize parametric coordinates
xx = zeros(m,k);    
yy = zeros(m,k);

% loop on arcs
for i = 1 : k
  j = ix(i);  
  if alpha(j) == 0, continue, end
  alist = 0 : alpha(j)/(m-1) : alpha(j);   % angles for this arc
  xx(:,i) = cos(alist) * r1(j);
  yy(:,i) = sin(alist) * r1(j);
end

% parameteric FOV circle
z3 = 0:pi/99:pi;
x3 = cos(z3) * r2 + a;
y3 = sin(z3) * r2;

figure(2); clf
plot(xx, yy, 'g', x3, y3, a, 0, 'o')
title(sprintf('FOV %d with integration arcs', ifov))
grid on; zoom on

