%
% compare old and new non-linearity correction codes
%

% load some random RDR data
load /asl/data/cris/ccast/rdr60/2013/216/RDR_d20130804_t1426085.mat

% instrument params
band = 'MW';
wlaser = 773.13;
opts = struct;
opts.resmode = 'lowres';
[inst, user] = inst_params(band, wlaser, opts);

% clean up the RDR data
[igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, 'd20130804_t1426085');
eng = d1.packet;
% clear d1 m1

% get count spectra
spec = igm2spec(igmMW, inst);

% select a FOV, FOR and scan
ifov = 3;
iscan = 10;
ies = find(igmSDR == 1 & igmFOR == 16);
iit = find(igmSDR == 1 & igmFOR == 0);
isp = find(igmSDR == 1 & igmFOR == 31);

ES = squeeze(spec(:, ifov, ies(iscan)));
IT = squeeze(spec(:, ifov, iit(iscan)));
SP = squeeze(spec(:, ifov, isp(iscan)));

% old nonlinearity correction files
opts.DClevel_file = '../inst_data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';

% load parameters for old nlc()
control = load(opts.DClevel_file);
control.NF = load(opts.cris_NF_file);
control.NF = control.NF.NF;

% call old non-linearity code
es1 = nlcX(band, ifov, inst.freq, ES, SP, eng.PGA_Gain, control);
it1 = nlcX(band, ifov, inst.freq, IT, SP, eng.PGA_Gain, control);

% new time-domain filter file
tfile = '../inst_data/FIR_19_Mar_2012.txt';
sNF = specNF(inst, tfile);
inst.sNF = sNF;

% load new filter into old format
c2 = load(opts.DClevel_file);
t2 = load(opts.cris_NF_file);
c2.NF = t2.NF;

c2.NF.mw = sNF;
c2.NF.mw_npoints_dm = inst.npts;
c2.NF.vmw = inst.freq;

% old non-linearity code with new filter
es2 = nlcX(band, ifov, inst.freq, ES, SP, eng.PGA_Gain, c2);
it2 = nlcX(band, ifov, inst.freq, IT, SP, eng.PGA_Gain, c2);

% new non-linearity code with new filter
es3 = nlc(band, ifov, inst.freq, ES, SP, eng.PGA_Gain, inst);
it3 = nlc(band, ifov, inst.freq, IT, SP, eng.PGA_Gain, inst);

% compare old and new
[isequal(es2, es3), isequal(it2, it3)]

% comparison plot
figure(1); clf
x = inst.freq;
plot(x, real(es1), x, imag(es1), x, real(es2), x, imag(es2))
legend('old real', 'old imag', 'new real', 'new imag')
grid on; zoom on


