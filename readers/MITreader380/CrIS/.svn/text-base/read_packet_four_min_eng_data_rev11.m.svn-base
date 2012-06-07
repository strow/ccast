%
%        (c) Copyright 2004 Massachusetts Institute of Technology
%
%        In no event shall M.I.T. be liable to any party for direct, 
%        indirect, special, incidental, or consequential damages arising
%        out of the use of this software and its documentation, even if
%        M.I.T. has been advised of the possibility of such damage.
%          
%        M.I.T. specifically disclaims any warranties including, but not
%        limited to, the implied warranties of merchantability, fitness
%        for a particular purpose, and non-infringement.
%
%        The software is provided on an "as is" basis and M.I.T. has no
%        obligation to provide maintenance, support, updates, enhancements,
%        or modifications.

function read_packet_four_min_eng_data_rev11

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint

packet_counter.four_min_eng = packet_counter.four_min_eng + 1;
packet.four_min_eng.time(packet_counter.four_min_eng)=timeval;
fprintf('Found 4-min PACKET %d (%x hex, current packet count is %d).\n', header.apid, header.apid,packet_counter.four_min_eng);

%*** PCE Application FSW Version and InstrumentID**************************
% Word 7
first_word=fread(fid,1,'uint16=>uint16');
packet.PceAppFswVer=bitshift(bitand(first_word, uint16(hex2dec('FFE0')) ),-5);
packet.InstrumentId = bitand(first_word, uint16(hex2dec('001F')) );
% Word 7

%*** Engineering packet update # ******************************************
% Word 8
packet.CRC = fread(fid, 1, 'ubit16');

%*** Engineering Packet_version *******************************************
% Words 9 
% Engineering Packet_version
packet.Eng_Packet_Ver=fread(fid, 1, 'ubit16');

% Word 10-11
% Neon laser wavelength 32 bit (8 digit BCD)
packet.Laser_Wavelength=BinReadBCD( fid, 1, 'u', 4, [4 4 4 4 4 4 4 4 ])';

% Word 12

% Midwave & Shortwave offset (ppm) 2's comp (8 bits)
packet.Midwave_offset=get_8bit_integer(fid);
packet.Shortwave_offset=get_8bit_integer(fid);
 
%*** ILS curve fit parameters**********************************************
% Words 13 to 822 DLM 11/14/08
%for h = 1:2 % sweep direction dependance
h=1;
for i = 1:3 % Band 
    for j = 1:9 % FOV 
        for k = 1:3 % 1 = lower band edge, 2 = upper band edge, 3 = mid band
            packet.ILS_Param.SweepDir(h).Band(i).FOV(j).c0(k) = fread(fid, 1, 'float32');
            packet.ILS_Param.SweepDir(h).Band(i).FOV(j).c1(k) = fread(fid, 1, 'float32');
            packet.ILS_Param.SweepDir(h).Band(i).FOV(j).c2(k) = fread(fid, 1, 'float32');
            packet.ILS_Param.SweepDir(h).Band(i).FOV(j).c3(k) = fread(fid, 1, 'float32');
            packet.ILS_Param.SweepDir(h).Band(i).FOV(j).c4(k) = fread(fid, 1, 'float32');
        end
    end
end

%*** ILS FOV offset and size parameters***************************************
% Words 823 to 909 DLM 11/14/08
% all parameters in 2's complement
for k = 1:3
    for h = 1:9
        packet.ILS_Param.Band(k).FOV(h).CrTrkOffset = fread(fid, 1, 'bit16');
    end
    for h = 1:9
        packet.ILS_Param.Band(k).FOV(h).InTrkOffset = fread(fid, 1, 'bit16');
    end
    for h = 1:9
        packet.ILS_Param.Band(k).FOV(h).FOV_Size = fread(fid, 1, 'bit16'); 
    end
    packet.ILS_Param.Band(k).FOV5_CrTrkMisalignment = fread(fid, 1, 'bit16');
    packet.ILS_Param.Band(k).FOV5_InTrkMisalignment = fread(fid, 1, 'bit16');
end

%*** Spares *******************************************************************
% Word 910: 1 Word -> 2 Bytes
% skip 2 bytes in file
% fseek(fid, 2, 'cof');
fread(fid,1,'uint16')

%*** Linearity Correction Parameters
% Word 911 to 1018
for k = 1:3
    for h = 1:9
        packet.Linearity_Param.Band(k).a2(h) = fread(fid, 1, 'float32');
    end
end
for k = 1:3
    for h = 1:9
        packet.Linearity_Param.Band(k).Vinst(h) = fread(fid, 1, 'float32');
    end
end
%*** Modulation efficiency *****************************************

% Word 1019 to 1072
for k = 1:3
	for h = 1:9
		packet.Modulation_eff.Band(k).Eff(h) = fread(fid, 1, 'float32');
	end
end
%*** PGA gain table map ******************************************************
% Word 1073 to 1134

for k = 1:3
packet.PGA_Gain.Band(k).map = BinReadBCD( fid, 16, 'u', 3, [4 4 4 4])';% number format i.e. 56.45
end
for k = 1:3
packet.PGA_Gain.Band(k).Setting= BinReadBCD( fid, 9, 'u', 3, [4 4])'; % unsigned binary i.e. 05
end

% Spare byte *****************************************************
% Word 1134 (8-15)
fseek(fid, 1, 'cof');

% FIR Tayloring *****************************************************
% Word 135 to 1140
for k = 1:3
packet.FIR_Gain.Band(k).gain= fread( fid,1,'float32'); % unsigned binary i.e. 05
end

% BinReadBCD(fid, NbValueToRead, Sign, DecimalPosition, Format);

%*** ICT Emissivity table *****************************************************
% Words 911 to 2502
% Words 1141 to 2445

packet.ICT_Param.Band(1).ICT.EffEmissivity.Pts(76:788,1) = BinReadBCD( fid, 713, 'u', 1, [4 4 4 4])';
packet.ICT_Param.Band(2).ICT.EffEmissivity.Pts(48:480,1) = BinReadBCD( fid, 433, 'u', 1, [4 4 4 4])';
packet.ICT_Param.Band(3).ICT.EffEmissivity.Pts(21:179,1) = BinReadBCD( fid, 159, 'u', 1, [4 4 4 4])';

packet.ICT_Param.Band(1).ICT.EffEmissivity.Pts(1:75,1) = ones(75,1)*packet.ICT_Param.Band(1).ICT.EffEmissivity.Pts(76,1);
packet.ICT_Param.Band(2).ICT.EffEmissivity.Pts(1:47,1) = ones(47,1)*packet.ICT_Param.Band(2).ICT.EffEmissivity.Pts(48,1);
packet.ICT_Param.Band(3).ICT.EffEmissivity.Pts(1:20,1) = ones(20,1)*packet.ICT_Param.Band(3).ICT.EffEmissivity.Pts(21,1);

packet.ICT_Param.Band(1).ICT.EffEmissivity.Pts(789:864,1) = ones(76,1)*packet.ICT_Param.Band(1).ICT.EffEmissivity.Pts(788,1);
packet.ICT_Param.Band(2).ICT.EffEmissivity.Pts(481:528,1) = ones(48,1)*packet.ICT_Param.Band(2).ICT.EffEmissivity.Pts(480,1);
packet.ICT_Param.Band(3).ICT.EffEmissivity.Pts(180:200,1) = ones(21,1)*packet.ICT_Param.Band(3).ICT.EffEmissivity.Pts(179,1);

%*** Polarization Change ******************************************************
% Words 2446 to 2724 
for f = 1:31 % 30 FOR + 1 DS
    for b = 1:3 %Inst.NbBand
        packet.PolCalParam.FOR(f).Band(b).PolarizationCorr.Pts = BinReadBCD( fid, 3, 's', 2, [3 4 4 4]); % 3 values for each band
    end;
end;

%*** Polarization wavenumbers *************************************************
% Words 2725 to 2733
for b=1:3 %Inst.NbBand
    packet.PolCalParam.Band(b).PolarizationWavenumber.Pts = BinReadBCD( fid, 3, 'u', 0, [4 4 4 4]);
end;

%*** ICT environment model ****************************************************
% Words 2734 to 2815

for k=1:3 %Inst.NbBand
    packet.ICT_Param.Band(k).Emissivity.ScanMirrorPts = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
end
  
for k=1:3 %Inst.NbBand
    packet.ICT_Param.Band(k).Emissivity.ScanBafflePts = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
end

for k=1:3 %Inst.NbBand
    packet.ICT_Param.Band(k).Emissivity.HousingPts = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
end;

for k=1:3 %Inst.NbBand
    packet.ICT_Param.Band(k).Emissivity.ICT_BafflePts = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
end

for k=1:3 %Inst.NbBand
    packet.ICT_Param.Band(k).Emissivity.EarthPts = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
end

packet.ICT_Param.View_Factor.BeamSplitterWarm = BinReadBCD(fid, 1, 'u', 2, [4 4 4 4]); % 0.086
packet.ICT_Param.View_Factor.BeamSplitterCold= BinReadBCD(fid, 1, 'u', 2, [4 4 4 4]); % 0.086
packet.ICT_Param.View_Factor.ScanBaffle = BinReadBCD(fid, 1, 'u', 2, [4 4 4 4]);
packet.ICT_Param.View_Factor.ICTBaffle = BinReadBCD(fid, 1, 'u', 2, [4 4 4 4]);
packet.ICT_Param.View_Factor.OMAandFrame= BinReadBCD(fid, 1, 'u', 2, [4 4 4 4]);
% added 12/11/09 DLM
packet.ICT_Param.View_Factor.OMA=0.059;
packet.ICT_Param.View_Factor.Frame=0.145;
packet.ICT_Param.View_Factor.Other=0.010;
%
packet.ICT_Param.View_Factor.Space = BinReadBCD(fid, 1, 'u', 2, [4 4 4 4]);
packet.ICT_Param.Earth_Temperature = fread(fid, 1, 'float32');
packet.ICT_Param.Scan_Baffle_Temp_Orbit= fread(fid, 21, 'float32');
packet.ICT_Param.Orbital_Period= fread(fid, 1, 'bit16'); 

% 2*16 spare bytes
% skip 32 bytes in file
fseek(fid, 32, 'cof');

%*** Science TLM coefficients *************************************************
% Words 2816 to 2885

packet.TempCoeffs.ICT_PRT1.Ro = fread(fid,1,'float32');
packet.TempCoeffs.ICT_PRT1.A = fread(fid,1,'float32');
packet.TempCoeffs.ICT_PRT1.B = fread(fid,1,'float32');

packet.TempCoeffs.ICT_PRT2.Ro = fread(fid,1,'float32');
packet.TempCoeffs.ICT_PRT2.A = fread(fid,1,'float32');
packet.TempCoeffs.ICT_PRT2.B = fread(fid,1,'float32');

packet.TempCoeffs.ICT_LowCalibResis.Ro = fread(fid,1,'float32');
packet.TempCoeffs.ICT_LowCalibResis.A = fread(fid,1,'float32');

packet.TempCoeffs.ICT_HighCalibResis.Ro = fread(fid,1,'float32');% word 2832
packet.TempCoeffs.ICT_HighCalibResis.A = fread(fid,1,'float32');

packet.TempCoeffs.ICT_IE_CCA_CalibResis.Ro = fread(fid,1,'float32');
packet.TempCoeffs.ICT_IE_CCA_CalibResis.A = fread(fid,1,'float32');

packet.LaserTempSlope = fread(fid, 1, 'float32');
packet.LaserCurrentSlope = fread(fid, 1, 'float32');

packet.TempCoeffs.Beamsplitter.Intercept = fread(fid, 1, 'float32');
packet.TempCoeffs.Beamsplitter.Slope = fread(fid, 1, 'float32');

% skip 2 words in file
dummy=fread(fid, 2, 'float32');

packet.TempCoeffs.ScanMirror.Intercept = fread(fid, 1, 'float32'); % word 2852
packet.TempCoeffs.ScanMirror.Slope = fread(fid, 1, 'float32');

packet.TempCoeffs.ScanBaffle.Intercept = fread(fid, 1, 'float32');
packet.TempCoeffs.ScanBaffle.Slope = fread(fid, 1, 'float32');

packet.TempCoeffs.OMA_1.Intercept = fread(fid, 1, 'float32'); % word 2850
packet.TempCoeffs.OMA_1.Slope = fread(fid, 1, 'float32');
packet.TempCoeffs.OMA_2.Intercept = fread(fid, 1, 'float32');
packet.TempCoeffs.OMA_2.Slope = fread(fid, 1, 'float32');

packet.TempCoeffs.Telescope.Slope = fread(fid, 1, 'float32');

packet.TempCoeffs.CoolerStage1.Slope = fread(fid, 1, 'float32');
packet.TempCoeffs.CoolerStage2.Slope = fread(fid, 1, 'float32');
packet.TempCoeffs.CoolerStage3.Slope = fread(fid, 1, 'float32');
packet.TempCoeffs.CoolerStage4.Slope = fread(fid, 1, 'float32');

packet.SSM.CrTrkPointErr.Intercept  = fread(fid, 1, 'float32');
packet.SSM.CrTrkPointErr.Slope  = fread(fid, 1, 'float32');
packet.SSM.InTrkPointErr.Intercept = fread(fid, 1, 'float32');
packet.SSM.InTrkPointErr.Slope = fread(fid, 1, 'float32');

%**************************** Science TLM limits ******************************
% Words 2886 to 2899

packet.TempDriftLimit.ICT_1 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.ICT_2 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.Beamsplitter = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);

% 16 spare bits, 16/8 = 2 bytes
% skip 2 bytes in file
fseek(fid, 2, 'cof');

packet.TempDriftLimit.ScanMirror = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.ScanBaffle = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.OMA_1 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.OMA_2 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.Telescope = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.CoolerStage1 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.CoolerStage2 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.CoolerStage3 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.TempDriftLimit.CoolerStage4 = BinReadBCD( fid, 1, 'u', 2, [4 4 4 4]);
packet.LaserWavelengthDriftLimit = BinReadBCD( fid, 1, 'u', 4, [4 4 4 4]);

%*** Mapping Parameters *******************************************************
% Words 2900 to 2961
%*** Commanded Cross-track angles (roll) **************************************
% (Earth, Pos #1 @ 30)
% (Nadir, Pos #32)
packet.MappingParam.CommandedCrTrk.ES = fread(fid, 30, 'bit32');
packet.MappingParam.CommandedCrTrk.Nadir = fread(fid, 1, 'bit32');

%*** Commanded In-track angle (pitch) *****************************************
% Words 2966 to 3023
packet.MappingParam.CommandedInTrk.ES = fread(fid, 30, 'bit32');
packet.MappingParam.CommandedInTrk.Nadir = fread(fid, 1, 'bit32');

%*** SSMR to SSMF angles ******************************************************
% Words 3024 to 3029
packet.MappingParam.SSMR_To_SSMF.Roll = fread(fid, 1, 'bit32');
packet.MappingParam.SSMR_To_SSMF.Pitch = fread(fid, 1, 'bit32');
packet.MappingParam.SSMR_To_SSMF.Yaw = fread(fid, 1, 'bit32');

%*** Spares *******************************************************************
% Words 3030 to 3031: 2 Words -> 4 Bytes
% skip 4 bytes in file
fseek(fid, 4, 'cof');

%*** IAR to SSMR angles *******************************************************
% Words 3032 to 3037
packet.MappingParam.IAR_To_SSMR.Roll = fread(fid, 1, 'bit32');
packet.MappingParam.IAR_To_SSMR.Pitch = fread(fid, 1, 'bit32');
packet.MappingParam.IAR_To_SSMR.Yaw = fread(fid, 1, 'bit32');

%*** Interferometer borsight to SSMF angle ************************************
% Words 3038 to 3041, 32 bit 2's complement
packet.MappingParam.IOAR_To_SSMF.Yaw = fread(fid, 1, 'bit32');
packet.MappingParam.IOAR_To_SSMF.Pitch = fread(fid, 1, 'bit32');

%*** SBF to IAR angles ********************************************************
% Words 3042 to 3047, 32 bit 2's complement
packet.MappingParam.SBF_To_IAR.Roll = fread(fid, 1, 'bit32');
packet.MappingParam.SBF_To_IAR.Pitch = fread(fid, 1, 'bit32');
packet.MappingParam.SBF_To_IAR.Yaw = fread(fid, 1, 'bit32');

%*** Time stamp bias **********************************************************
% Word 3048
packet.MappingParam.TimeStampBias = fread(fid, 1, 'bit16'); 

%**************************** CrIS Bit Trim Mask LW, MW, SW ******************************
% Words 3049 to 3144
for b=1:3
    for k=1:16
        packet.BitTrimMask.Band(b).StopBit(k) = fread(fid, 1, 'ubit8');
        packet.BitTrimMask.Band(b).StartBit(k) = fread(fid, 1, 'ubit8');
        packet.BitTrimMask.Band(b).Index(k) = fread(fid, 1, 'ubit16');
    end
    
    % Transpose to column vectors (required format in ReadIGMPacket -> RemoveBTMask)
    packet.BitTrimMask.Band(b).StopBit = packet.BitTrimMask.Band(b).StopBit';
    packet.BitTrimMask.Band(b).StartBit = packet.BitTrimMask.Band(b).StartBit';
    packet.BitTrimMask.Band(b).Index = packet.BitTrimMask.Band(b).Index';
    
end

%*** Spare *******************************************************************
% Words 3145 to 3145: 1 Words -> 2 Bytes
dummy=fread(fid,1,'bit32');


%*** Tilt Correction Algorithm Parameters *************************************
% Words 3146 to 3210

dummy=fread(fid,64,'bit16');

% for b=1:3
%         packet.OPDSampleJitter.Band(b).K1 = fread(fid, 1, 'bit16');
%     for k=1:9
%         packet.OPDSampleJitter.Band(b).b(k) = fread(fid, 1, 'bit16');
%         packet.OPDSampleJitter.Band(b).a(k) = fread(fid, 1, 'bit16');
%     end
%         %Two or three spare words
%         if b<3
%         dummy=fread(fid,3,'bit16')
%         else
%         dummy=fread(fid,2,'bit16')
%         end
% end

%*** LW, MW, SW Data Extraction Information ***********************************
% Words 3211 to 3216
% Not used by SDR Algorithms.
packet.DataExtInfo=fread(fid,6,'ubit16');

% Words 3218 to 3224
%*** Spectral calibration data ************************************************
packet.NeonCal.LaserFringeCount = fread(fid, 1, 'ubit16');
packet.NeonCal.NbCalibrationSweeps = fread(fid, 1, 'ubit16');
packet.NeonCal.NeonGasWavelength = BinReadBCD( fid, 1, 'u', 4, [4 4 4 4 4 4 4 4]);
packet.NeonCal.TimeStamp.Days = fread(fid, 1, 'ubit16');
packet.NeonCal.TimeStamp.msec = fread(fid, 1, 'ubit32');
packet.NeonCal.RepeatCalibTime = fread(fid, 1, 'ubit16');

%**************************** Neon cal data ***********************************
% Words 3225 to 3864

% error changed 127 to 128 on july 6 2006 DLM

for k=1:128
    packet.NeonCal.NeonStartingCount(k) = fread(fid, 1, 'ubit16');
    packet.NeonCal.NeonStartingPartialCount(k) = fread(fid, 1, 'ubit16');
    packet.NeonCal.NeonFringeCount(k) = fread(fid, 1, 'ubit16');
    packet.NeonCal.NeonEndingPartialCount(k) = fread(fid, 1, 'ubit16');
    packet.NeonCal.NeonEndingCount(k) = fread(fid, 1, 'ubit16');   
end
%**************************** End


if VERBOSE
v=datevec(timeval);
fprintf('Found PACKET %d (%x hex) sec=  %12.6f .\n', header.apid, header.apid, v(5)*60+v(6));
end  

function a=get_8bit_integer(fid)
        mask=uint8(2^8-1);
        idx =(bitand(fread(fid, 1, '*uint8'),mask));
        a=single(idx);
        if(a>128);a=a-256;end;
