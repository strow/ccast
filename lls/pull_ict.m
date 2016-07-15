cd /asl/s1/strow/ccast/2016/018
a = dir('CAL*.mat');
for i=1:length(a)
   load(a(i).name);
   cal(i).FORTime = FORTime;
   cal(i).lw = squeeze(allLWIT(5,1,:,:));
   i
end
CAL_d20160118_t1121021.mat