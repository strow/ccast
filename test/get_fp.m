function [fp] = get_fp(band,srf_name);

% fp.s is true version of sdef
% fp.d is    
   
%            y             x   
sdef = [     
   1      19198.62      19198.62
   2             0      19198.62
   3     -19198.62      19198.62
   4      19198.62             0
   5             0             0
   6     -19198.62             0
   7      19198.62     -19198.62
   8             0     -19198.62
   9     -19198.62     -19198.62 ];

% IN TEMPORARY STATE, CHANGE FP.D(1:2) SIGNS, ONLY CORRECT FOR NPP RIGHT NOW

switch srf_name
%--------------------------------------------------------------    
  case 'default'
    switch band
      case 'LW'
        fp.s = sdef;
        fp.d = [0 0 0];
        fp.ppm = zeros(1,9);
      case 'MW'
        fp.s = sdef;
        fp.d = [0 0];
      case 'SW'
        fp.s = sdef;
        fp.d = [0 0 0];
    end
    fp = mod_fp(fp);
%--------------------------------------------------------------  
  case 'umbc1'
    switch band
      case 'LW'
        fp.s = sdef;
        fp.d = [-606 -31];
        fp.ppm = [0 0 0 0 0 0 0 0 0];
      case 'MW'
        fp.s = sdef;
        fp.d = [-658 -32];
        fp.ppm = [0 0 0 0 0 0 0 0 0];
      case 'SW'
        fp.s = sdef;
        fp.d = [-614 -10];
        fp.ppm = [0 0 0 0 0 0 0 0 0];
    end
%--------------------------------------------------------------  
  case 'umbc2'
    switch band
      case 'LW'
         fp.s = sdef;
         dnew = [5 9 99];  % add these to umbc1
         % From umbc1 MN LW (after r fit)
         fp.ppm = [0.4 0.8 -1.0 -1.0 0 -0.5 1.0 -2.8 2.0];
         fp.d = [-606 -31 0] + dnew;
         fp = mod_fp(fp);
      case 'MW'
        fp.s = sdef;
        dnew = [0 22 -25];
        fp.ppm = [-0.3 0.6 0 0 0 -0.6 0.1 -0.1 0.3];
        fp.d = [-658 -32 0] + dnew;
        fp = mod_fp(fp);
      case 'SW'
        fp.s = sdef;
        dnew = [9 16 -63];
        fp.d = [-614 -10 0] + dnew;
        fp.ppm = [-1.1 1.4 -0.5 0.8 0 0.6 -0.2 0.7 -0.7];
        fp = mod_fp(fp);
    end
%--------------------------------------------------------------  
  case 'umbc3'
    switch band
      case 'LW'
         fp.s = sdef;
         dnew = [0 0 0];  % add these to umbc1 + umbc2
         fp.ppm_umbc2 = [0.4 0.8 -1.0 -1.0 0 -0.5 1.0 -2.8 2.0];
         fp.ppm = [-0.5 -0.5 -1.3 0.3 0 -1.0 -0.5 -1.3 -1.3];
         fp.ppm = fp.ppm + fp.ppm_umbc2;
         fp.d = [-606 -31 0] + [5 9 99] + dnew;
         fp = mod_fp(fp);
      case 'MW'  % NO CHANGE: == UMBC2
        fp.s = sdef;
        dnew = [0 22 -25];
        fp.ppm = [-0.3 0.6 0 0 0 -0.6 0.1 -0.1 0.3];
        fp.d = [-658 -32 0] + dnew;
        fp = mod_fp(fp);
      case 'SW' % NO CHANGE: == UMBC2
        fp.s = sdef;
        dnew = [9 16 -63];
        fp.d = [-614 -10 0] + dnew;
        fp.ppm = [-1.1 1.4 -0.5 0.8 0 0.6 -0.2 0.7 -0.7];
        fp = mod_fp(fp);
    end
%--------------------------------------------------------------  
  case 'npp'
% dg_v33a_* are the NPP focal planes.  These do NOT break out the
% radial shift.  Instead it is implemented via residual./alpha where
% residual is what's left after an x,y shift.  So, below fp.d(3) is set
% to zero and fp.s has the radial scaling built-in
% Note that I am switching signs on the offsets below from the past
% so to be compatible with engr packet and other FP's in this routine
    switch band
      case 'LW'
        load /asl/matlib/cris/dg_v33a_lw
      case 'MW'  % NO CHANGE: == UMBC2
        load /asl/matlib/cris/dg_v33a_mw
      case 'SW' % NO CHANGE: == UMBC2
        load /asl/matlib/cris/dg_v33a_sw
    end
    fp.foax_from_dg = dg.s';
    fp.s(:,1) = 1:9;
    fp.s(:,2) = dg.sy*1E6;
    fp.s(:,3) = dg.sx*1E6;
    fp.d(1) = -1E6*dg.align_offset_y;
    fp.d(2) = -1E6*dg.align_offset_x;
    fp.d(3) = 0;  % by definition
    fp.rad = dg.Rtheta*1E6;
    fp.ppm = [0 0 0 0 0 0 0 0 0];  % already applied
    fp = mod_fp(fp);

% %--------------------------------------------------------------  
%   case 'test1'
%     switch band
%       case 'LW'
%          fp.s = sdef;
%          fp.d = [-337.81 161.56  84.22];
%          fp.ppm = [0 0 0 0 0 0 0 0 0];
%          fp = mod_fp(fp);
%       case 'MW'  % NO CHANGE: == UMBC2
%         fp.s = sdef;
%         dnew = [0 22 -25];
%         fp.ppm = [-0.3 0.6 0 0 0 -0.6 0.1 -0.1 0.3];
%         fp.d = [-658 -32 0] + dnew;
%         fp = mod_fp(fp);
%       case 'SW' % NO CHANGE: == UMBC2
%         fp.s = sdef;
%         dnew = [9 16 -63];
%         fp.d = [-614 -10 0] + dnew;
%         fp.ppm = [-1.1 1.4 -0.5 0.8 0 0.6 -0.2 0.7 -0.7];
%         fp = mod_fp(fp);
%     end
%--------------------------------------------------------------  
  case 'exelis'
    switch band
      case 'LW'
        fp.s = [
           1    19193    19193
           2        0    19283
           3   -19173    19173
           4    19256        0
           5       0         0
           6   -19256        0
           7    19342   -19342
           8        0   -19283
           9   -19354   -19354];
        fp.d = [-516  91];
      case 'MW'
        fp.s = [
           1    19176    19176
           2        0    19211
           3   -19184    19184
           4    19194        0
           5       0         0
           6   -19194        0
           7    19199   -19199
           8        0   -19211
           9   -19210   -19210
               ];
        fp.d = [-582  0];
      case 'SW'
        fp.s = [
           1    19125    19125
           2        0    19182
           3   -19136    19136
           4    19194        0
           5       0         0
           6   -19168        0
           7    19164   -19164
           8        0   -19182
           9   -19156   -19156
               ];
        fp.d = [-578  13];
    end
%--------------------------------------------------------------  
end
end
%--------------------------------------------------------------  
function fp = mod_fp(fp);

dr = fp.d(3);
% s(:,2) == y
% s(:,3) == x
fpang = atan2(fp.s(:,2),fp.s(:,3));
id = [1:4 6:9];  % FOV5 angle no good and not needed
fp.s(id,3) = fp.s(id,3) + dr.*cos(fpang(id));
fp.s(id,2) = fp.s(id,2) + dr.*sin(fpang(id));
% Now have to add in FOV by FOV changes that a single dr can't fix
c     = -1/36.8;
s     = -1/52.2;
alpha = [ c s c s 0 s c s c];
% This is individual dr, starting with fp.ppm (ppm units)
dr = -(fp.ppm./alpha)'; % Got the minus wrong for a long time!!
dr(5) = 0;  % So, no id needed here
fp.s(:,3) = fp.s(:,3) + dr.*cos(fpang(:));
fp.s(:,2) = fp.s(:,2) + dr.*sin(fpang(:));
% Compute foax (all needed for ccast, in ccast units)
fp.foax = sqrt( (fp.s(:,3) + fp.d(2)).^2 + (fp.s(:,2) + fp.d(1)).^2);
fp.foax = 1E-6*fp.foax;  % compatible with ccast

end
%--------------------------------------------------------------  
