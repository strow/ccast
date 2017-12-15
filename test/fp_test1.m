%
% cris 1 focal plane specs from the eng packet
% this should agree with the ccast v33a focal plane
%

load /asl/data/cris/ccast/sdr60/2017/091/SDR_d20170401_t1229445.mat

% LW band 1 x and y offsets
eng.ILS_Param.Band(1)

fovLWx = NaN(9, 1); fovLWy = NaN(9, 1);
fovMWx = NaN(9, 1); fovMWy = NaN(9, 1);
fovSWx = NaN(9, 1); fovSWy = NaN(9, 1);

for i = 1 : 9
 radLW = eng.ILS_Param.Band(1).FOV(i).FOV_Size;
 radMW = eng.ILS_Param.Band(2).FOV(i).FOV_Size;
 radSW = eng.ILS_Param.Band(3).FOV(i).FOV_Size;

 fovLWx(i) = eng.ILS_Param.Band(1).FOV(i).CrTrkOffset;
 fovLWy(i) = eng.ILS_Param.Band(1).FOV(i).InTrkOffset;
 fovMWx(i) = eng.ILS_Param.Band(2).FOV(i).CrTrkOffset;
 fovMWy(i) = eng.ILS_Param.Band(2).FOV(i).InTrkOffset;
 fovSWx(i) = eng.ILS_Param.Band(3).FOV(i).CrTrkOffset;
 fovSWy(i) = eng.ILS_Param.Band(3).FOV(i).InTrkOffset;
end

LWdx = eng.ILS_Param.Band(1).FOV5_CrTrkMisalignment;
LWdy = eng.ILS_Param.Band(1).FOV5_InTrkMisalignment;
MWdx = eng.ILS_Param.Band(2).FOV5_CrTrkMisalignment;
MWdy = eng.ILS_Param.Band(2).FOV5_InTrkMisalignment;
SWdx = eng.ILS_Param.Band(3).FOV5_CrTrkMisalignment;
SWdy = eng.ILS_Param.Band(3).FOV5_InTrkMisalignment;

foaxLW = sqrt((fovLWx + LWdx).^2 + (fovLWy + LWdy).^2) / 1e6;
foaxMW = sqrt((fovMWx + MWdx).^2 + (fovMWy + MWdy).^2) / 1e6;
foaxSW = sqrt((fovSWx + SWdx).^2 + (fovSWy + SWdy).^2) / 1e6;

fradLW = radLW / 1e6;
fradMW = radMW / 1e6;
fradSW = radSW / 1e6;

[foax, frad] = fp_v33a('LW');
c1 = (foax - foaxLW) ./ foaxLW

[foax, frad] = fp_v33a('MW');
c2 =(foax - foaxMW) ./ foaxMW

[foax, frad] = fp_v33a('SW');
c3 = (foax - foaxSW) ./ foaxSW

[c1, c2, c3]

