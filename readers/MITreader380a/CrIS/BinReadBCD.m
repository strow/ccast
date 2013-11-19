function [ Values ] = BinReadBCD(fid, NbValueToRead, Sign, DecimalPosition, Format)

% Read binary coded decimal data.
%
% Description: 
%   Read binary coded decimal data.
%
% Usage:
%   [Values] = BinReadBCD(fid, NbValueToRead, Sign, DecimalPosition, Format);
%
% Input:
%   fid: File identifier.
%   NbValueToRead: Number of values to read.
%   Sign: Sign string:
%     's':signed, first bit gives the sign: 1 -> - , 0 -> +,
%     'u':unsigned.
%   DecimalPosition: Decimal point position (1 -> 0.1234  2 -> 1.234).
%   Format: [3 3 3 3] -> 4 digits / 3 bits per digit
%
% Output:
%   Values: Decoded decimal values.
%

% Authors:
%   Martin Levert (MLV), Simon Dubé (SDB).
%
% Change Record:
%   Date         By   Description
%   04-Sep-2003  SDB  Updated header.
%   01-Jul-2002  MLV  First version creation.
%
% COPYRIGHT (C) ABB-BOMEM INC
%
%  ABB Inc.,
%  Analytical and Advanced Solutions
%  585, Boul. Charest Est, bureau 300
%  Quebec, (Quebec) G1K 9H4 CANADA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Decimal = [];

switch Sign
case 'u'
    
    for k = 1 : NbValueToRead
        
        NbBitsPerValue = sum(Format);
        
        UBCD = (fread(fid, NbBitsPerValue, 'ubit1'))';
        
        Values(k) = UBCDToDecimal(UBCD, DecimalPosition, Format);
        
    end
    
case 's'

    for k = 1 : NbValueToRead
        
        NbBitsPerValue = sum(Format) + 1; % +1 est le bit de signe
        
        SBCD = (fread(fid, NbBitsPerValue, 'ubit1'))';
        
        Values(k) = SBCDToDecimal(SBCD, DecimalPosition, Format);
        
    end
end
