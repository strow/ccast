function [ IntN ] = BitsToIntN(Bits, NbBits, Flip)

% Convert bits into a IntN structure.
%
% Description:
%    Converts NbBits bits into a IntN structure.
%
% Usage:
%   [IntN] = BitsToIntN(Bits, NbBits, Flip);
%
% Input:
%   Bits: Bit stream vector.
%   NbBits: Number of bits in the integer.
%   Flip: Bit stream is flipped left-right ('Y'), or left as is ('N').
%
% Output:
%   IntN: Structure that holds 
%     .Nb: bit number to indicate how many bits in the (MATLAB type casted)
%           double are really used.
%     .Val: (MATLAB type casted) double to store the integer value.
%

% Authors: 
%   Martin Levert (MLV),Simon Dubé (SDB).
%
% Change Record:
%   Date         By   Description
%   04-Sep-2003  SDB  Updated header.
%   01-Jul-2002  MLV  First version creation.
%
% COPYRIGHT (C) ABB-BOMEM INC
%
%  ABB-Bomem Inc.,
%  585, Boul. Charest Est, bureau 300
%  Quebec, (Quebec) G1K 9H4 CANADA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

len = length(Bits);

if Flip == 'Y'
    Bits = fliplr(Bits);
end

powers = [NbBits - 1 : -1 : 0];
powers = 2.^powers;

%Preallocation pour rapidite du code
NbIntN = ceil(len/NbBits);
IntN.Val = zeros([1 NbIntN]);


CurBit = 1;
for i= 1 : NbIntN
    
    % prends NbBits ou on est rendu
    if (CurBit + NbBits - 1) <= len
        Temp = Bits(CurBit : CurBit + NbBits - 1);
        CurBit = CurBit + NbBits;
        IntN.Nb(i)= NbBits;
    else
        Temp = Bits(CurBit : len);
        Temp = cat(2,zeros([1 (NbBits-(len-CurBit+1))]), Temp);
        IntN.Nb(i) = len-CurBit+1;
        CurBit = len;
    end
    
    IntN.Val(i) = sum(Temp.*powers);
end