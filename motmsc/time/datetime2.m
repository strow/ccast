% 
% datetime demo, try to do correct leap second conversions
%
% try tai to dtime and the reverse

% regular matlab UTC times
U58 = datetime('1958-01-01');
U93 = datetime('1993-01-01');
U93 = datetime('2012-02-01 00:02:10');

% UTC times with leap seconds
L58 = datetime('1958-01-01T00:00:00.000Z','timezone','UTCLeapSeconds');
L93 = datetime('1993-01-01T00:00:00.000Z','timezone','UTCLeapSeconds');
L93 = datetime('2012-02-01T00:02:10.000Z','timezone','UTCLeapSeconds');

% try to get L93 from U93
Q93 = U93;
Q93.TimeZone = 'UTCLeapSeconds'
Q93.Year   = U93.Year;
Q93.Month  = U93.Month;
Q93.Day    = U93.Day;
Q93.Hour   = U93.Hour;
Q93.Minute = U93.Minute;
Q93.Second = U93.Second;

isequal(L93, Q93)

% TAI time for 1993
T93 = 12784 * 86400 + 27;
T93 = 19754 * 86400 + 34 + 130;

dU = seconds(U93 - U58);   % regular Matlab UTC difference
dL = seconds(L93 - L58);   % UTC difference with UTCLeapSeconds
dQ = seconds(Q93 - L58);   % UTC difference with UTCLeapSeconds

T93 - dU    % the matlab time diff is wrong by 27 seconds
T93 - dL    % the matlab time diff is wrong by 10 seconds
T93 - dQ

