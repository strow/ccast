%          (c) Copyright 2004 Massachusetts Institute of Technology
%
%          In no event shall M.I.T. be liable to any party for direct, 
%          indirect, special, incidental, or consequential damages arising
%          out of the use of this software and its documentation, even if
%          M.I.T. has been advised of the possibility of such damage.
%          
%          M.I.T. specifically disclaims any warranties including, but not
%          limited to, the implied warranties of merchantability, fitness
%          for a particular purpose, and non-infringement.
%
%          The software is provided on an "as is" basis and M.I.T. has no
%          obligation to provide maintenance, support, updates, enhancements,
%          or modifications.   
second_word = fread(fid,1,'uint16');
header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK),-14);
header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
header.packet_length = fread(fid,1,'uint16');	


% read the UTC time codes
if noUTC,
    [day,msec_of_day,usec_of_msec] = read_utc(fid);
    clear day msec_of_day usec_of_msec
end

%sftwr=fread(fid,1,'uint8'); % software version variable
%sftwr_vrsn=[num2str(bin2dec(num2str(bitget(sftwr,5:8)))) '.' num2str(bin2dec(num2str(bitget(sftwr,1:4))))];
%clear sftwr
%instrSN=fread(fid,1,'uint8'); % instrument serial number

% Read Software Version and Inst. Serial Number
sftwr_iSN = fread(fid, 1, 'uint16');

sftvr_b = bitand(sftwr_iSN, sum(2.^[0:3]));
sftvr_a = bitshift(bitand(sftwr_iSN, sum(2.^[4:7])), -4);
sftwr_vrsn = [num2str(sftvr_a) '.' num2str(sftvr_b)];

instrSN = bitshift(sftwr_iSN, -8);

fprintf(['Satellite software version = ' sftwr_vrsn '\n'])

% Correct for h5 file values - Mark Tolman 3/16/2011
if instrSN < 49,
    instrSN = 50;
end

  if instrSN==49,
      fprintf('Instrument S/N is Engineering Design Unit (EDU)\n')
  elseif instrSN==50,
      fprintf('Instrument S/N is ProtoFlight Module (PFM)\n')
  elseif instrSN==51,
      fprintf('Instrument S/N is Flight Module - 1 (FM-1)\n')
  elseif instrSN==52,
      fprintf('Instrument S/N is Flight Module - 2 (FM-2)\n')
  elseif instrSN==53,
      fprintf('Instrument S/N is Flight Module - 3 (FM-3)\n')    
  elseif instrSN==54,
      fprintf('Instrument S/N is Flight Module - 4 (FM-4)\n')
  elseif instrSN==55,
      fprintf('Instrument S/N is Flight Module - 5 (FM-5)\n')
  else
      fprintf('***************** Didn''t recognize Instrument S/N! ********************\n')
  end

          
          
    