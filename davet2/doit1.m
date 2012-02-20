
echo on

load ../RDR_d20100906_t0425319.mat

Nkeep = 4;

% Compute ICT temps
ict_temps = cris_ICT_countsToK_CCAST(d1.data.sci.Temp,d1.packet.TempCoeffs,Nkeep)

% Compute other instr temps
instr_temps = cris_calc_instrument_temps_CCAST(d1.data.sci.Temp.Temp,d1.packet.TempCoeffs,Nkeep)

% Create array of structures
T = soa2aos(ict_temps);
T = soa2aos(instr_temps,T)

% Extract one record
T_CRIS = T(1)

% and compute ICT temperature
T_ICT = 0.5 * T_CRIS.T_PRT1 + 0.5 * T_CRIS.T_PRT2

% Define spectral band and metrology laser wavelength and resulting user and sensor grids and parameters
band = 'lw';
wl_laser = 775.18675;
[user,sensor] = cris_spectral_params_CCAST(band,wl_laser);

% Compute predicted radiance from ICT (on the sensor wavenumber grid)
B = cris_ICTradModel_CCAST(band,sensor.v,T_ICT,T_CRIS,d1.packet.ICT_Param,1,NaN,1,NaN)

% Extract complex IFGs for a given Earth Scene, ICT and Space:
iFov = 5;
iRecord = 5;

switch band
case 'lw'
 es_ifg = d1.idata.LWES(:,iFov,iRecord) + sqrt(-1)* d1.qdata.LWES(:,iFov,iRecord);
 sp_ifg = d1.idata.LWSP(:,iFov,iRecord) + sqrt(-1)* d1.qdata.LWSP(:,iFov,iRecord);
 it_ifg = d1.idata.LWIT(:,iFov,iRecord) + sqrt(-1)* d1.qdata.LWIT(:,iFov,iRecord);
case 'mw'
 es_ifg = d1.idata.MWES(:,iFov,iRecord) + sqrt(-1)* d1.qdata.MWES(:,iFov,iRecord);
 sp_ifg = d1.idata.MWSP(:,iFov,iRecord) + sqrt(-1)* d1.qdata.MWSP(:,iFov,iRecord);
 it_ifg = d1.idata.MWIT(:,iFov,iRecord) + sqrt(-1)* d1.qdata.MWIT(:,iFov,iRecord);
case 'sw'
 es_ifg = d1.idata.SWES(:,iFov,iRecord) + sqrt(-1)* d1.qdata.SWES(:,iFov,iRecord);
 sp_ifg = d1.idata.SWSP(:,iFov,iRecord) + sqrt(-1)* d1.qdata.SWSP(:,iFov,iRecord);
 it_ifg = d1.idata.SWIT(:,iFov,iRecord) + sqrt(-1)* d1.qdata.SWIT(:,iFov,iRecord);
end

% Compute spectra
es_cxs = fft(fftshift(es_ifg));es_cxs = es_cxs(user.flipindex);
sp_cxs = fft(fftshift(sp_ifg));sp_cxs = sp_cxs(user.flipindex);
it_cxs = fft(fftshift(it_ifg));it_cxs = it_cxs(user.flipindex);


% Apply Nonlinearity correction to scene, ICT, and space views
[es_nlc,extra] = cris_nlc_CCAST(band,iFov,sensor.v,es_cxs,sp_cxs,d1.packet.PGA_Gain);
[sp_nlc,extra] = cris_nlc_CCAST(band,iFov,sensor.v,sp_cxs,sp_cxs,d1.packet.PGA_Gain);
[it_nlc,extra] = cris_nlc_CCAST(band,iFov,sensor.v,it_cxs,sp_cxs,d1.packet.PGA_Gain);


% plot magnitude spectra before and after NL correction
clf;eval(['nf = extra.control.NF.' band ';'])
plot(sensor.v,abs(es_cxs),sensor.v,abs(es_nlc).*nf,...
     sensor.v,abs(it_cxs),sensor.v,abs(it_nlc).*nf,...
     sensor.v,abs(sp_cxs),sensor.v,abs(sp_nlc).*nf)
xlabel('wavenumber');ylabel('Mag(counts)');grid
legend('ES raw','ES with NLC','ICT raw','ICT with NLC','Space raw','Space with NLC')
print -depsc doit1a.eps


% Do the radiometric calibration
R1 = (es_nlc - sp_nlc)./(it_nlc - sp_nlc) .* B.total;


% Compute phases and difference phases for diagnostics
% TO BE FILLED IN


% Apply rolloffs in band guard regions
R2 = cris_rolloffs_CCAST(sensor.v,real(R1),sensor.vb);


% Plot real and imaginary parts of calibrated spectrum
clf;plot(sensor.v,real(R1),sensor.v,imag(R1),'r',sensor.v,R2);
xlabel('wavenumber');ylabel('Radiance')
legend('Real(Rad)','Imag(Rad)','Real(Rad) with rolloffs');grid
print -depsc doit1b.eps


% Define FOV angles
FOVangle = 0.0272;    % ideal corner FOV
%FOVangle = 0.0192;   % ideal side FOV
%FOVangle = 0;        % ideal center FOV
FOVradius = 7/833;    % ideal FOV radius

% Compute Self Apodization correction matrix
isa = cris_computeISA_CCAST(sensor.v,sensor.MOPD,FOVangle,FOVradius);

% Do the self apodization correction
R3 = isa * R2;

% Plot spectra before and after SA correction
clf;plot(sensor.v,R2,sensor.v,R3,'r');
xlabel('wavenumber');ylabel('Radiance')
legend('R2','R3');grid
print -depsc doit1c.eps

% Resample the spectra and normalize the resolution to the user grid
R4 = cris_spectral_resample_CCAST(R3,user,sensor);

% Plot spectra before and after resampling
clf;plot(sensor.v,R3,user.v,R4,'r');
xlabel('wavenumber');ylabel('Radiance')
legend('R3','R4');grid
print -depsc doit1d.eps


% Plot all steps
v = sensor.v;
clf;plot(v,R1,'.-',v,R2,'.-',v,R3,'.-',user.v,R4,'.-')
xlabel('wavenumber');ylabel('Radiance')
legend('R1','R2','R3','R4');grid
print -depsc doit1e.eps
