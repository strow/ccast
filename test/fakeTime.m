%
% fakeTime - return expected granule obs times
%
% synopsis
%   [tf, ix] = fakeTime(t0, ns, gi, k)
%
% inputs
%   t0 - sequence start, IET time
%   ns - number of scans per file
%   gi - file index, 1 = first file
%   k  - obs index shift, 0-34, 0 = no shift
%
% output
%   tf - 34 * ns vector of IET obs time for file index gi
%   ix - 34 * ns vector of obs FOR index for the tf times
%
% discussion
%   fakeTime builds a valid obs time sequence from start time,
%   scans/file, file index, and obs index starting offset
%
%   the obs index shift is mainly intended for tests where fakeTime
%   is used to simulate RDR times that can start with any obs
%
%   obs index: 1-30 ES FORs, 31-32 SP looks, 33-34 IT looks
%
%                               scan times
%   200 200 ...  200  200  200 200 200  200  200 200 200  200  200  200
%   ES1 ES2 ... ES29 ES30 slew SP1 SP2 slew slew IT1 IT2 slew slew slew
%    1   2        29   30   31  32  33   34   35  36  37   38   39   40
%
% internal variables
%   t1 - relative obs times in ms for an n+1 scan granule
%

function [tf, ix] = fakeTime(t0, ns, gi, k)

% sweep times in ms relative to scan start
tx = (0:39) * 200;  % all sweep start times
tES = tx(1:30);     % earth scene start times
tSP = tx(32:33);    % space look start times
tIT = tx(36:37);    % ITC look start times

% loop on ns + 1 scans
t1 = [];
for i = 0 : ns
  t2 = [tES, tSP, tIT] + 8000 * i;
  t1 = [t1, t2];
end

% obs time sequence
tf = t0 + 1000 * (t1 + (gi-1) * ns * 8000);
ix = repmat(1:34, 1, ns+1);

% obs times index shift
tf = tf((k+1):(k+ns*34))';
ix = ix((k+1):(k+ns*34))';

