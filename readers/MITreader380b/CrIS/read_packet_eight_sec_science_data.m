function read_packet_eight_sec_science_data

% changes
% 10/2/09 add data to data.sci. data structure 
% 10/2/08 only save the mean of the 40 temp measurments in each eight
% second periond.

% derived from code below
% COPYRIGHT (C) ABB-BOMEM INC
%
%  ABB Inc.,
%  Advanced and Analytical Solutions
%  585, Boul. Charest Est, bureau 300
%  Quebec, (Quebec) G1K 9H4 CANADA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
   
   
delta_days=-17167; % delta_days=days_CrIS_epoch-days_SQL_epoch 

% is_not_eof=read_packet_time_header;
       
%*** PCE Application FSW Version and Instrument ***************************
packet.PceAppFswVer = fread(fid, 1, 'ubit11');
packet.InstrumentId = fread(fid, 1, 'ubit5');

% Initialize data structures
packet.Temp.time = zeros(40, 1);
packet.Temp.IE_CCA_CalibResTemp.Pts = zeros(40, 1);
packet.Temp.ICT_1.Pts = zeros(40, 1);
packet.Temp.ICT_2.Pts = zeros(40, 1);
packet.Temp.ICT_LowCalibResis.Pts = zeros(40, 1);
packet.Temp.ICT_HighCalibResis.Pts = zeros(40, 1);
packet.MappingParam.SSM.CrTrkPointErr.Pts = zeros(30, 1);
packet.MappingParam.SSM.InTrkPointErr.Pts = zeros(30, 1);

mask=uint16(2^14-1);

for k=1:40
    
    if k==39
        packet.LaserCurrent = get_14bit_integer(fid);
    end;
    packet.Temp.IE_CCA_CalibResTemp.Pts(k) = get_14bit_integer(fid);
    packet.Temp.ICT_LowCalibResis.Pts(k) = get_14bit_integer(fid);
    packet.Temp.ICT_HighCalibResis.Pts(k) = get_14bit_integer(fid);
    packet.Temp.ICT_1.Pts(k) = get_14bit_integer(fid);
    packet.Temp.ICT_2.Pts(k) = get_14bit_integer(fid);
    
    if (k >= 4 && k <= 33)
        packet.MappingParam.SSM.CrTrkPointErr.Pts(k-3) = get_14bit_integer(fid);
        packet.MappingParam.SSM.InTrkPointErr.Pts(k-3)  = get_14bit_integer(fid);           
    end;
    if k==39
        packet.LaserTemp = get_14bit_integer(fid);       
        packet.Temp.Beamsplitter = get_14bit_integer(fid);
        packet.Temp.OMA_1 = get_14bit_integer(fid);
        packet.Temp.OMA_2 = get_14bit_integer(fid);         
        packet.Temp.ScanMirror = get_14bit_integer(fid);        
        packet.Temp.ScanBaffle = get_14bit_integer(fid);
        packet.Temp.CoolerStage2 = get_14bit_integer(fid);        
        packet.Temp.CoolerStage4 = get_14bit_integer(fid);        
        packet.Temp.CoolerStage1 = get_14bit_integer(fid);        
        packet.Temp.CoolerStage3 = get_14bit_integer(fid);        
        packet.Temp.Telescope = get_14bit_integer(fid);        

    end;
end;

packet_counter.eight_sec_science = packet_counter.eight_sec_science + 1;

% change on 10/2/08
%--------------------------------------------------------------------------
% do not keep 40  measurements from each sience packet, use the means and
% keep the packet_counter index.

% ii=(1:40)+(packet_counter.eight_sec_science-1)*40;
ii=packet_counter.eight_sec_science;
data.sci.Temp.time(ii)=header.time+mean( (0:39)*2.314814814814815e-006 );
data.sci.Temp.IE_CCA_CalibResTemp.Pts(ii) = mean( packet.Temp.IE_CCA_CalibResTemp.Pts);
data.sci.Temp.ICT_1.Pts(ii) = mean( packet.Temp.ICT_1.Pts);
data.sci.Temp.ICT_2.Pts(ii) = mean( packet.Temp.ICT_2.Pts);
data.sci.Temp.ICT_LowCalibResis.Pts(ii) = mean( packet.Temp.ICT_LowCalibResis.Pts);
data.sci.Temp.ICT_HighCalibResis.Pts(ii) = mean( packet.Temp.ICT_HighCalibResis.Pts);
%--------------------------------------------------------------------------

data.sci.Temp.time(packet_counter.eight_sec_science)=header.time;
data.sci.Temp.IE_CCA_CalibResTemp.Pts(packet_counter.eight_sec_science) = mean(packet.Temp.IE_CCA_CalibResTemp.Pts);
data.sci.Temp.ICT_1.Pts(packet_counter.eight_sec_science) = mean(packet.Temp.ICT_1.Pts);
data.sci.Temp.ICT_2.Pts(packet_counter.eight_sec_science) = mean(packet.Temp.ICT_2.Pts);
data.sci.Temp.ICT_LowCalibResis.Pts(packet_counter.eight_sec_science) = mean(packet.Temp.ICT_LowCalibResis.Pts);
data.sci.Temp.ICT_HighCalibResis.Pts(packet_counter.eight_sec_science) = mean(packet.Temp.ICT_HighCalibResis.Pts);
data.sci.Temp.LaserTemp(packet_counter.eight_sec_science)=packet.LaserTemp;
data.sci.Temp.Temp.Beamsplitter(packet_counter.eight_sec_science)=packet.Temp.Beamsplitter;
data.sci.Temp.Temp.Telescope(packet_counter.eight_sec_science)=packet.Temp.Telescope;
data.sci.Temp.Temp.OMA_1(packet_counter.eight_sec_science)=packet.Temp.OMA_1;
data.sci.Temp.Temp.OMA_2(packet_counter.eight_sec_science)=packet.Temp.OMA_2;
data.sci.Temp.Temp.ScanMirror(packet_counter.eight_sec_science)=packet.Temp.ScanMirror;
data.sci.Temp.Temp.ScanBaffle(packet_counter.eight_sec_science)=packet.Temp.ScanBaffle;
data.sci.Temp.Temp.CoolerStage1(packet_counter.eight_sec_science)=packet.Temp.CoolerStage1;
data.sci.Temp.Temp.CoolerStage2(packet_counter.eight_sec_science)=packet.Temp.CoolerStage2;
data.sci.Temp.Temp.CoolerStage3(packet_counter.eight_sec_science)=packet.Temp.CoolerStage3;
data.sci.Temp.Temp.CoolerStage4(packet_counter.eight_sec_science)=packet.Temp.CoolerStage4;
data.sci.MappingParam.SSM.CrTrkPointErr.Pts=packet.MappingParam.SSM.CrTrkPointErr.Pts;
data.sci.MappingParam.SSM.InTrkPointErr.Pts=packet.MappingParam.SSM.InTrkPointErr.Pts;

% timeval=header.time;
% sci.Temp.time=header.time;
% sci.Temp.LaserTemp=packet.LaserTemp;
% sci.Temp.Beamsplitter=packet.Temp.Beamsplitter;
% sci.Temp.Telescope=packet.Temp.Telescope;
% sci.Temp.OMA_1=packet.Temp.OMA_1;
% sci.Temp.OMA_2=packet.Temp.OMA_2;
% sci.Temp.ScanMirror=packet.Temp.ScanMirror;
% sci.Temp.ScanBaffle=packet.Temp.ScanBaffle;
% sci.Temp.CoolerStage1=packet.Temp.CoolerStage1;
% sci.Temp.CoolerStage2=packet.Temp.CoolerStage2;
% sci.Temp.CoolerStage3=packet.Temp.CoolerStage3;
% sci.Temp.CoolerStage4=packet.Temp.CoolerStage4;
% sci.Temp.IE_CCA_CalibResTemp = mean(packet.Temp.IE_CCA_CalibResTemp.Pts);
% sci.Temp.ICT_1 = mean(packet.Temp.ICT_1.Pts);
% sci.Temp.ICT_2 = mean(packet.Temp.ICT_2.Pts);
% sci.Temp.ICT_LowCalibResis = mean(packet.Temp.ICT_LowCalibResis.Pts);
% sci.Temp.ICT_HighCalibResis = mean(packet.Temp.ICT_HighCalibResis.Pts);
% sci.MappingParam.SSM.CrTrkPointErr=packet.MappingParam.SSM.CrTrkPointErr.Pts;
% sci.MappingParam.SSM.InTrkPointErr=packet.MappingParam.SSM.InTrkPointErr.Pts;

% time_sci=sci.Temp.time;
% 
% mym(['replace INTO sci_data (time,sci) VALUES ("{Sn}","{M}")'],fix(time_sci*1.e10),sci);



function a=get_14bit_integer(fid)
        mask=uint16(2^14-1);
        idx =(bitand(fread(fid, 1, '*uint16'),mask));
        a=single(idx);
        if(a>8192);a=a-16384;end;

