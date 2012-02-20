function NEW = soa2aos(IN,OLD);

%
% function NEW = soa2aos(IN,OLD);
%
% Convert an input structure of arrays "IN" to an output array of structures 
% "NEW".  All fields in "IN" should be vectors of the same dimension.
%
% E.g. goes from IN.x(i), IN.y(i), IN.z(i) to NEW(i).x, NEW(i).y, NEW(i).z
%
% Inputs:
%         IN:      The input structure of arrays
%         OLD:     (Optional) input array of sructures.  If supplied, the output
%                  array of structures will be added to an existing array of 
%                  structures "OLD".  Structures in OLD should (most likely) be the 
%                  same dimension as arrays in IN, although no checking is done for 
%                  this, nor is there any checking of array/structure variable name 
%                  conflicts between IN and OLD.
%
% Outputs:
%         new:     Output array of structures.
%
% DCT 11/6/2011
%

if nargin == 2
  NEW = OLD;
end

fnames = fieldnames(IN);
for i = 1:length(fnames);
  fstr = fnames{i};
  for j = 1:length(IN.(fstr))
    NEW(j).(fstr) = IN.(fstr)(j);
  end
end

