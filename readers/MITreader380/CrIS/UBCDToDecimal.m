function [ Decimal ] = UBCDToDecimal(UBCD, DecimalPosition, Format)

% Convert unsigned binary coded decimal to decimal data.
%
% Description: 
%   Convert unsigned binary coded decimal to decimal data.
%
% Usage:
%   [Decimal] = UBCDToDecimal(UBCD, DecimalPosition, Format);
%
% Input:
%   UBCD: Unsigned binary coded decimal data.
%   DecimalPosition: Decimal point position (1 -> 0.1234  2 -> 1.234).
%   Format: [3 3 3 3] -> 4 digits / 3 bits per digit.
%
% Output:
%   Decimal: Decimal value (type casted as double by MATLAB).
%

% Authors:
%   Martin Levert (MLV), Simon Dubé (SDB).
%
% Change Record:
%   Date         By   Description
%   08-Sep-2003  SDB  Updated header.
%   01-Jul-2002  MLV  First version creation.
%
% COPYRIGHT (C) ABB-BOMEM INC
%
%  ABB Inc.,
%  Analytical and Advanced Solutions
%  585, Boul. Charest Est, bureau 300
%  Quebec, (Quebec) G1K 9H4 CANADA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = [];
CurBit = 1;
Count = 1;

if DecimalPosition == 1
    str = '0';
end

for k = 1:length(Format)
    if DecimalPosition == Count
        str = [ str '.' ];
    end
    
    Digit = BitsToIntN(UBCD(CurBit:CurBit + Format(k) - 1), Format(k),'N');
    Digit = Digit.Val;
    str = [ str num2str(Digit)];
    
    CurBit = CurBit + Format(k);
    Count = Count + 1;
end

Decimal = str2num(str);