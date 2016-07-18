cd /asl/s1/strow/ccast/2016/018

a = dir('CAL*.mat');
for i=1:length(a)
   load(a(i).name);
   cal(i).FORTime = FORTime;
   cal(i).lwit = allLWIT;
   cal(i).lwsp = allLWSP;
   cal(i).mwit = allMWIT;
   cal(i).mwsp = allMWSP;
   cal(i).swit = allSWIT;
   cal(i).swsp = allSWSP;
   i
end

lw_size = size(allLWIT);
mw_size = size(allMWIT);
sw_size = size(allSWIT);

clear all*

 shome = '/asl/s1/strow/ccast'
%shome = '/asl/s1/strow/Data'
sdir = fullfile(shome, '2016', '018');

disp('LWIT');
sm_LWIT = cal_smooth(cal,'lwit',lw_size);
disp('LWSP');
sm_LWSP = cal_smooth(cal,'lwsp',lw_size);
disp('MWIT');
sm_MWIT = cal_smooth(cal,'mwit',mw_size);
disp('MWSP');
sm_MWSP = cal_smooth(cal,'mwsp',mw_size);
disp('SWIT');
sm_SWIT = cal_smooth(cal,'swit',sw_size);
disp('SWSP');
sm_SWSP = cal_smooth(cal,'swsp',sw_size);

for i=1:length(a)
  ctmp = ['S' a(i).name];
  fn_sm = fullfile(sdir,ctmp);
  out_LWIT = sm_LWIT(i).lwit;
  out_LWSP = sm_LWSP(i).lwsp;
  out_MWIT = sm_MWIT(i).mwit;
  out_MWSP = sm_MWSP(i).mwsp;
  out_SWIT = sm_SWIT(i).swit;
  out_SWSP = sm_SWSP(i).swsp;
  save(fn_sm,'out_LWIT','out_LWSP','out_MWIT','out_MWSP','out_SWIT','out_SWSP');
end

