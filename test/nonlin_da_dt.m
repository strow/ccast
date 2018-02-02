%
% get and apply da2/dTb to adjust a2 weights
%

d1 = load('a2v3_ref');
d2 = load('a2v3_p10');

% get brightness temps
frq = d1.frq;
b1 = rad2bt(frq, d1.fmean);
b2 = rad2bt(frq, d2.fmean);

% comparison interval
ix = 750 <= frq & frq <= 1000;

% Tb diff: d2.Tb - d1.Tb
db = b2 - b1;
db = db(ix,:);
db = mean(db)';

% d1 FOV 7 diff
db7 = b1 - b1(:,7);
db7 = db7(ix,:);
db7 = mean(db7)';

% UW a2v3 values
a2tmp = [
  0.0153      0         0
  0.0175      0         0
  0.0167      0         0
  0.0154      0         0
  0.0336      0         0
  0.0110      0         0
  0.0094      0         0
  0.0204      0         0
  0.0095      0.0943    0
];

% a2 diff: d2.a2 - d1.a2
da = a2tmp(:,1) * 0.1;

da2 = (da ./ db) .* (-db7)


