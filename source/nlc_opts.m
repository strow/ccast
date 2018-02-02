%
% nlc options from inst, eng, and opts structs, by band
%

function nopt = nlc_opts(inst, eng, opts)

% initialize output
nopt = struct;

% band index
switch upper(inst.band)
  case 'LW', bi = 1;
  case 'MW', bi = 2;  
  case 'SW', bi = 3;
  otherwise, error('bad band spec');
end

% spectral space numeric filter
nopt.sNF = specNF(inst, opts.NF_file);

% normalize NPP numeric filter to match UW-SSEC 2008 values
if strcmp(opts.nlc_alg, 'NPP')
  switch upper(inst.band)
    case 'LW',  nopt.sNF = 1.6047 * nopt.sNF ./ max(nopt.sNF);
    case 'MW',  nopt.sNF = 0.9826 * nopt.sNF ./ max(nopt.sNF);
    case 'SW',  nopt.sNF = 0.2046 * nopt.sNF ./ max(nopt.sNF);
  end
elseif ~strcmp(opts.nlc_alg, 'ATBD')
  error(['bad value for nlc_alg ', opts.nlc_alg])
end

% nlc params from eng
a2 = eng.Linearity_Param.Band(bi).a2;
cm = eng.Modulation_eff.Band(bi).Eff;
cp = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
Vinst = eng.Linearity_Param.Band(bi).Vinst;

% nlc params from opts
switch inst.band
  case 'LW', 
    if isfield(opts, 'a2LW'),       a2 = opts.a2LW; end;
    if isfield(opts, 'cpLW'),       cp = opts.cpLW; end;
    if isfield(opts, 'VinstLW'), Vinst = opts.VinstLW; end;
  case 'MW', 
    if isfield(opts, 'a2MW'),       a2 = opts.a2MW; end;
    if isfield(opts, 'cpMW'),       cp = opts.cpMW; end;
    if isfield(opts, 'VinstMW'), Vinst = opts.VinstMW; end;
  case 'SW', 
    if isfield(opts, 'a2SW'),       a2 = opts.a2SW; end;
    if isfield(opts, 'cpSW'),       cp = opts.cpSW; end;
    if isfield(opts, 'VinstSW'), Vinst = opts.VinstSW; end;
end

% copy values out
nopt.a2 = a2(:);
nopt.cm = cm(:);
nopt.cp = cp(:);
nopt.Vinst = Vinst(:);

