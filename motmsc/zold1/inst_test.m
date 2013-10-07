%
% compare old and new versions of inst_params
%

blist = {'lw', 'mw', 'sw'};
rlist = {'lowres', 'hires1', 'hires2'};
wlaser = 773.1301;

for i = 1 : 3
  for j = 1 : 3
    band = blist{i};
    opts.resmode = rlist{j};
    [inst1, user1] = inst_params(band, wlaser, opts);
    [inst2, user2] = inst_params2(band, wlaser, opts);
    [i, j, isequal(inst1, inst2), isequal(user1, user2)]
  end
end

