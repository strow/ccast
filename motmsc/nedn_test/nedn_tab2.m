%
% nedn_tab2 -- save left singular vectors from tabulated NEdN data
%
% This script loads nedn_tab.mat from nedn_tab1.m and generates and
% saves left singular vectors for use in a principal component filter.
%

% NEdN data
% load nedn_tab_HR
  load nedn_tab_LR

% number of basis vectors
kLW = 6;
kMW = 5;
kSW = 4;

nLW = length(vLW);
nMW = length(vMW);
nSW = length(vSW);

uLW = zeros(nLW, kLW, 9, 2);
uMW = zeros(nMW, kMW, 9, 2);
uSW = zeros(nSW, kSW, 9, 2);

for di = 1 : 2     % loop on sweep direction
  for fi = 1 : 9   % loop on FOVs

    nedn = squeeze(nLWtab(:, fi, di, :));
    [u,s,v] = svd(nedn, 0);
    uLW(:,:,fi,di) = u(:, 1:kLW);

    nedn = squeeze(nMWtab(:, fi, di, :));
    [u,s,v] = svd(nedn, 0);
    uMW(:,:,fi,di) = u(:, 1:kMW);

    nedn = squeeze(nSWtab(:, fi, di, :));
    [u,s,v] = svd(nedn, 0);
    uSW(:,:,fi,di) = u(:, 1:kSW);

  end
end

  save nedn_filt_LR vLW vMW vSW uLW uMW uSW
% save nedn_filt_HR vLW vMW vSW uLW uMW uSW

