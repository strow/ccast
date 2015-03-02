%
% compare old and new non-linearity correction codes
%

addpath utils
addpath ../davet
addpath ../source

% load a sample ccast RDR file
load /asl/data/cris/ccast/rdr60_hr/2015/005/RDR_d20150105_t1948024.mat
rid = 'd20150104_t0804144';

% process sci and eng packtes
eng = struct([]);
[sci, eng] = scipack(d1, eng);

% get the current wlaser
wlaser = metlaser(eng.NeonCal);

% get instrument params
band = 'SW';
opts = struct;
opts.resmode = 'hires2';
[inst, user] = inst_params(band, wlaser, opts);

% clean up the RDR data
[igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);

% get count spectra
spec = igm2spec(igmMW, inst);

% select a FOV, FOR, scan, and sweep dir
iFOV = 9;
iscan = 24;
iES = find(igmSDR == 1 & igmFOR == 16);
iIT = find(igmSDR == 1 & igmFOR == 0);
iSP = find(igmSDR == 1 & igmFOR == 31);

ES = squeeze(spec(:, :, iES(iscan)));
IT = squeeze(spec(:, :, iIT(iscan)));
SP = squeeze(spec(:, :, iSP(iscan)));

ESf = ES(:, iFOV);
ITf = IT(:, iFOV);
SPf = SP(:, iFOV);

% get the time-domain filter
tfile = '../inst_data/FIR_19_Mar_2012.txt';
sNF = specNF(inst, tfile);
inst.sNF = sNF;

% old non-linearity correction
es_old = nlc(inst, iFOV, ESf, SPf, eng);
it_old = nlc(inst, iFOV, ITf, SPf, eng);

% new non-linearity correction 
es_new = nlc_ng(inst, iFOV, ESf, SPf, eng);
it_new = nlc_ng(inst, iFOV, ITf, SPf, eng);

% vectorized non-linearity correction 
es_vec = nlc_vec(inst, ES, SP, eng);
it_vec = nlc_vec(inst, IT, SP, eng);

% compare old and new
[isclose(es_new, es_old), isclose(it_new, it_old)]
[isclose(es_new, es_vec(:, iFOV)), isclose(it_new, it_vec(:, iFOV))]
