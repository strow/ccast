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

function initialize_packet_structures

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint

data.read.SQL=1;
data.read.HK=1;
data.read.HK_Tel_dwell=1;
data.read.SSM_Tel_dwell=1;
data.read.IM_Tel_dwell=1;
data.read.interferograms=1;
data.read.diag_intergerograms=1;
data.eng_4min_On=1;
data.eng_4min_ver=1;
packet.read_four_min_packet=0;

% all_packets=[];  DLM changed 12/16/2010 to prevent clearing, now used for
% unpack_8sec_of_data

MaxES = 120;
MaxSP = 8;
MaxIT = 8;
MaxDiag=120;
% 
% NLW=868;
% NMW=532;
% NSW=204;
% 
% % extended resolution
% NLW=868;
% NMW=1040;
% NSW=800;

% prealocate idata & qdata space to increase speed
% NOTE THE STORAGE MUST BE ON 4 byte BOUNDARIES
% idata.LWES=zeros(NLW,9,MaxES);
% idata.MWES=zeros(NMW,9,MaxES);
% idata.SWES=zeros(NSW,9,MaxES);
% idata.LWSP=zeros(NLW,9,MaxSP);
% idata.MWSP=zeros(NMW,9,MaxSP);
% idata.SWSP=zeros(NSW,9,MaxSP);
% idata.LWIT=zeros(NLW,9,MaxIT);
% idata.MWIT=zeros(NMW,9,MaxIT);
% idata.SWIT=zeros(NSW,9,MaxIT);
% qdata.LWES=zeros(NLW,9,MaxES);
% qdata.MWES=zeros(NMW,9,MaxES);
% qdata.SWES=zeros(NSW,9,MaxES);
% qdata.LWSP=zeros(NLW,9,MaxSP);
% qdata.MWSP=zeros(NMW,9,MaxSP);
% qdata.SWSP=zeros(NSW,9,MaxSP);
% qdata.LWIT=zeros(NLW,9,MaxIT);
% qdata.MWIT=zeros(NMW,9,MaxIT);
% qdata.SWIT=zeros(NSW,9,MaxIT);

data.ESflags.Scan_Status_Flags=zeros(3,9,MaxES);
data.ESflags.Impulse_Noise_Count=zeros(3,9,MaxES);
data.ESflags.ZPD_Amplitude=zeros(3,9,MaxES);
data.ESflags.ZPD_Location=zeros(3,9,MaxES);
data.ESflags.Number_of_Convert_Pulses=zeros(3,9,MaxES);
data.ESflags.Filter_Status_Upper_Register=zeros(3,9,MaxES);
data.ESflags.Filter_Status_Lower_Register=zeros(3,9,MaxES);
data.ESflags.Num_I_Words_After_Bit_Trimming=zeros(3,9,MaxES);

data.ITflags.Scan_Status_Flags=zeros(3,9,MaxIT);
data.ITflags.Impulse_Noise_Count=zeros(3,9,MaxIT);
data.ITflags.ZPD_Amplitude=zeros(3,9,MaxIT);
data.ITflags.ZPD_Location=zeros(3,9,MaxIT);
data.ITflags.Number_of_Convert_Pulses=zeros(3,9,MaxIT);
data.ITflags.Filter_Status_Upper_Register=zeros(3,9,MaxIT);
data.ITflags.Filter_Status_Lower_Register=zeros(3,9,MaxIT);
data.ITflags.Num_I_Words_After_Bit_Trimming=zeros(3,9,MaxIT);

data.SPflags.Scan_Status_Flags=zeros(3,9,MaxSP);
data.SPflags.Impulse_Noise_Count=zeros(3,9,MaxSP);
data.SPflags.ZPD_Amplitude=zeros(3,9,MaxSP);
data.SPflags.ZPD_Location=zeros(3,9,MaxSP);
data.SPflags.Number_of_Convert_Pulses=zeros(3,9,MaxSP);
data.SPflags.Filter_Status_Upper_Register=zeros(3,9,MaxSP);
data.SPflags.Filter_Status_Lower_Register=zeros(3,9,MaxSP);
data.SPflags.Num_I_Words_After_Bit_Trimming=zeros(3,9,MaxSP);


for i = 1:9
packet_counter.LWES(i) = 0;
packet_counter.MWES(i) = 0;
packet_counter.SWES(i) = 0;
packet_counter.LWSP(i) = 0;
packet_counter.MWSP(i) = 0;
packet_counter.SWSP(i) = 0;  
packet_counter.LWIT(i) = 0;
packet_counter.MWIT(i) = 0;
packet_counter.SWIT(i) = 0;
end

packet_counter.LWDIA = 0;
packet_counter.MWDIA = 0;
packet_counter.SWDIA = 0;
packet_counter.SSM_Tel_dwell = 0;
packet_counter.IM_Tel_dwell = 0;
packet_counter.HK_Tel_dwell = 0;
packet_counter.four_min_eng = 0;
packet_counter.eight_sec_science = 0;
packet_counter.diary_data=0;

for i=1:8
    packet_counter.HK(i)=0;
end


packet.error=0;
packet.LWES.time=[];
packet.MWES.time=[];
packet.SWES.time=[];
packet.LWIT.time=[];
packet.MWIT.time=[];
packet.SWIT.time=[];
packet.LWSP.time=[];
packet.MWSP.time=[];
packet.SWSP.time=[];


sweep_direction.LWES=[];
sweep_direction.MWES=[];
sweep_direction.SWES=[];
sweep_direction.LWIT=[];
sweep_direction.MWIT=[];
sweep_direction.SWIT=[];
sweep_direction.LWSP=[];
sweep_direction.MWSP=[];
sweep_direction.SWSP=[];
sweep_direction.LWDIA=[];
sweep_direction.MWDIA=[];
sweep_direction.SWDIA=[];

FOR.LWES=[];
FOR.MWES=[];
FOR.SWES=[];
FOR.LWIT=[];
FOR.MWIT=[];
FOR.SWIT=[];
FOR.LWSP=[];
FOR.MWSP=[];
FOR.SWSP=[];
FOR.LWDIA=[];
FOR.MWDIA=[];
FOR.SWDIA=[];

maxSci = 5 * 8 * 4;

data.sci.Temp.time = zeros(1, maxSci);
data.sci.Temp.LaserTemp = zeros(1, maxSci);
data.sci.Temp.Temp.Beamsplitter = zeros(1, maxSci);
data.sci.Temp.Temp.Telescope = zeros(1, maxSci);
data.sci.Temp.Temp.OMA_1 = zeros(1, maxSci);
data.sci.Temp.Temp.OMA_2 = zeros(1, maxSci);
data.sci.Temp.Temp.ScanMirror = zeros(1, maxSci);
data.sci.Temp.Temp.ScanBaffle = zeros(1, maxSci);
data.sci.Temp.Temp.CoolerStage1 = zeros(1, maxSci);
data.sci.Temp.Temp.CoolerStage2 = zeros(1, maxSci);
data.sci.Temp.Temp.CoolerStage3 = zeros(1, maxSci);
data.sci.Temp.Temp.CoolerStage4 = zeros(1, maxSci);

maxICT = 40 * 5 * 8 * 4;

data.sci.Temp.ICT_1.Pts = zeros(1, maxICT);
data.sci.Temp.ICT_2.Pts = zeros(1, maxICT);
data.sci.Temp.ICT_LowCalibResis.Pts = zeros(1, maxICT);
data.sci.Temp.ICT_HighCalibResis.Pts = zeros(1, maxICT);

data.T.cold=90;
data.T.warm=290;
data.T.target=287;
data.T.ECT_reference=0;

% diagnostic mode interferograms
data.LW.number_of_pulses(1) = 0;
data.LW.ZPD_amplitude(1) = 0;
data.LW.ZPD_location(1) = 0;
data.LW.No_conv_pulses(1) = 0;
data.MW.number_of_pulses(1) = 0;
data.MW.ZPD_amplitude(1) = 0;
data.MW.ZPD_location(1) = 0;
data.MW.No_conv_pulses(1) = 0;
data.SW.number_of_pulses(1) = 0;
data.SW.ZPD_amplitude(1) = 0;
data.SW.ZPD_location(1) = 0;
data.SW.No_conv_pulses(1) = 0;

diagint.LW.int = zeros(21038, MaxDiag);
diagint.MW.int = zeros(10854, MaxDiag);
diagint.SW.int = zeros(5506, MaxDiag);

data.HK_time=[];
data.HK=zeros(8,1,42,'uint16');
data.HK8=zeros(1,619,'uint16');


end