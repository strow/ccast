%
% NAME
%   cris_ugrid -- return CrIS user grid with guard channels
%
% SYNOPSIS
%   ugrid = cris_ugrid(user, ng)
%
% INPUTS
%   user    - user struct from inst_params
%   ng      - number of guard channels (default 0)
%
% OUTPUTS
%   ugrid   - cris user grid with guard channels
%
% DISCUSSION
%   The grid setup vbase + (0 : n-1) * dv is for numeric stability.
%   The matlab fucion linspace is probably just as good but will not
%   be better than the above.
%
% AUTHOR
%  H. Motteler, 18 Sep 2014
%

function ugrid = cris_ugrid(user, ng)

% default is no guard channels
if nargin == 1
 ng = 0;
end

nbase = round((user.v2 - user.v1) / user.dv) + 1;
ugrid = user.v1 - ng * user.dv + (0 : nbase + 2*ng -1) * user.dv;

