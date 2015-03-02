%
% NAME
%   newILS -- CrIS ILS function
%
% SYNOPSIS
%   ILS = newILS(ifov, inst, vref, vgrid, opts)
%
% INPUTS
%   ifov   - FOV index
%   inst   - cris sensor grid params
%   vref   - channel or reference frequency
%   vgrid  - output frequency grid
%   opts   - optional parameters
%
% opts fields
%   narc   - number of arcs, default 1000
%   wrap  - 'sinc' (default), 'psinc n', 'psinc n*d'
%
% OUTPUTS
%   ILS    - ILS for vref at vgrid frequencies
%
% DISCUSSION
%   derived from cris_igm3, in the cris_sim repo.
%
% AUTHOR
%  H. Motteler, 14 May 2014
%

function ILS = newILS(ifov, inst, vref, vgrid, opts)

% defaults
narc = 1000;
wrap = 'sinc';

% options
if nargin == 5
  if isfield(opts, 'narc'), narc = opts.narc; end
  if isfield(opts, 'wrap'), wrap = opts.wrap; end
end

% set integral parameters
a  = inst.foax(ifov);   % FOV off-axis angle
r2 = inst.frad(ifov);   % FOV radius
b = max(0, a - r2);     % min off-axis angle  
d = a + r2 - b;         % integral angle span

% find integration weights
r1 = b : d/(narc-1) : a + r2;      % integral discrete angle steps
x = (a^2 + r1.^2 - r2^2) / (2*a);  % x val of FOV and arc intersection
alpha = real(acos(x ./ r1));       % angle to FOV and arc intersection 
w = alpha .* r1;                   % integral half-arc lengths
w = w / sum(w);                    % normalize the weights

% initialize the ILS
ILS = zeros(length(vgrid), 1);

% choose the ILS type
switch wrap
  case 'sinc'
    for i = 1 : narc
      ILS = ILS + w(i) * sinc(2*inst.opd*(vgrid - vref*cos(r1(i))));
    end
  case 'psinc n'
    for i = 1 : narc
      N = inst.npts;
      ILS = ILS + w(i) * psinc(2*inst.opd*(vgrid - vref*cos(r1(i))), N);
    end
  case 'psinc n*d'
    N = inst.npts * inst.df;
    for i = 1 : narc
      ILS = ILS + w(i) * psinc(2*inst.opd*(vgrid - vref*cos(r1(i))), N);
    end
  otherwise
    error(['bad value for wrap: ', wrap])
end

% plot the integration weights
% figure(4); clf; 
% plot(r1, w)
% title(sprintf('FOV %d integration weights', ifov))
% xlabel('off-axis angle'); 
% ylabel('weight')
% grid on; zoom on

end % newILS

%
% NAME
%   psinc -- normalized periodic sinc
%
% SYNOPSIS
%   y = psinc(x, n)
%

function y = psinc(x, n)

x = x * pi;

y = sin(x) ./ (n * sin(x/n));

y(find(x==0)) = 1;

end

