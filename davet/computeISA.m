
function [isa,sa] = computeISA(sensor,iFov);

%
% function [isa,sa] = computeISA(sensor,iFov);
%
% Compute a self-apodization correction matrix
%
% Inputs:
%   sensor     Structure of sensor grid parameters/variables for
%              LW, MW, or SW, from spectral_params.m
%   iFov       FOV index (1-9)
%
% Outputs:
%   isa        Inverse of the Self-Apodization matrix, such that
%              corrected spectra = isa * rad;
%
% History:
%   DCT, 14 Nov 2011, guts pulled from computeIls.m
%   DCT, 10 Dec 2011, adapted to sensor variable name changes
%              and use FOV dependent sensor grids and MOPDs.
%

%% Off-axis weights
[nu_over_nu0,weight] = offAxisWeights(sensor.FOVangle(iFov),sensor.FOVradius(iFov));

%% ON-AXIS wavenumber grid, MaxOPD, and channel centers
v = sensor.v_onaxis;      
MOPD = sensor.MOPD_onaxis;
v0 = sensor.v_onaxis;

%% Compute the SA matrix
sa = zeros(length(v));
for iChan = 1:length(v)

  % Sum the (shifted) pure sincs with the weights to get the expected ILS
  v_weight = nu_over_nu0 * v0(iChan);
  ils = zeros(length(v),1);
  for i = 1:length(weight);if weight(i) ~= 0
    ils = ils + weight(i)*nu_over_nu0(i)^2 * sinc( (v-v_weight(i)) * 2*MOPD*nu_over_nu0(i));
    %ils = ils + weight(i)*nu_over_nu0(i)   * sinc( (v-v_weight(i)) * 2*MOPD);
  end;end
  sa(:,iChan) = ils;
end

% And the inverse
isa = inv(sa);

