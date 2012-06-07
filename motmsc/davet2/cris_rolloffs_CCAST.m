
function rout = cris_rolloffs_CCAST(vin,rin,vb)

%
% function rout = cris_rolloffs_CCAST(vin,rin,vb)
%
% Apply cosine roll-offs to edges of an input spectrum
%
% Inputs:
%  [vin,rin]: input wavenumbers,radiances
%  vb       : [4x1] boundaries where roll-off function is applied
%             On the low wavenumber region, cosine rolloffs are inserted
%             between vb(1) and vb(2) and zeros are returned below vb(1).
%             On the high wavenumber region, cosine rolloffs are inserted 
%             between vb(3) and vb(4) and zeros are returned above vb(4).
%
% Outputs:
%  rout: modified radiances
%
% DCT, 14-Nov-2011, just a renamed version of rolloff2.m
%

rout = rin;

% For lower wavenumber end
ind = find(vin < vb(1));
rout(ind) = 0;
ind = find(vin >= vb(1) & vin <= vb(2));
temp=ind-min(ind);temp=temp/max(temp);
rout(ind) = rin(max(ind)+1)*(sin(temp*pi-pi/2)*0.5+0.5);

% For upper wavenumber end
ind = find(vin > vb(4));
rout(ind) = 0;
ind = find(vin >= vb(3) & vin <= vb(4));
temp=ind-min(ind);temp=temp/max(temp);
rout(ind) = rin(min(ind)-1)*(cos(temp*pi)*0.5+0.5);

