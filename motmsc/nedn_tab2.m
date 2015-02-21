%
% nedn_tab2 -- save left singular vectors from tabulated NEdN data
%

% NEdN data
load nedn_tab

% number of basis vectors
k = 8;

nLW = length(vLW);
nMW = length(vMW);
nSW = length(vSW);

uLW = zeros(nLW, k, 9, 2);
uMW = zeros(nMW, k, 9, 2);
uSW = zeros(nSW, k, 9, 2);

for si = 1 : 2     % loop on sweep direction
  for fi = 1 : 9   % loop on FOVs

    nedn = squeeze(nLWtab(:, fi, si, :));
    [u,s,v] = svd(nedn, 0);
    uLW(:,:,fi,si) = u(:, 1:k);

    nedn = squeeze(nMWtab(:, fi, si, :));
    [u,s,v] = svd(nedn, 0);
    uMW(:,:,fi,si) = u(:, 1:k);

    nedn = squeeze(nSWtab(:, fi, si, :));
    [u,s,v] = svd(nedn, 0);
    uSW(:,:,fi,si) = u(:, 1:k);

  end
end

save nedn_filt vLW vMW vSW uLW uMW uSW

