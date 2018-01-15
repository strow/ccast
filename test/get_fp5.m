function [fp] = get_fp(band,srf_name);
%--------------------------------------------------------------  
% Default focal plane geometry   
%--------------------------------------------------------------  
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
%--------------------------------------------------------------  
   switch srf_name
%---------------------------------------------------------------------------    
     case 'j1v2b'
       switch band
         case 'LW'
           fp.s     = sdef;
           fp.dfoax = zeros(1,9)
           fp.d     =  [-503.0  53.7  0];
           fp.ppm   = -[ 3.8   1.1  3.1   2.4   0.0   2.0   1.4  3.8   2.8 ];
         case 'MW'
           fp.s     = sdef;
           fp.dfoax = zeros(1,9)
           fp.d     =  [-565.5   11.2 0];
           fp.ppm   = -[ 3.3   1.1  2.1  1.1 0.0   0.9   2.0   0.7   3.6 ];
         case 'SW'
           fp.s     = sdef;
           fp.dfoax = zeros(1,9)
           fp.d     =  [-324.1  18.7 0];
           fp.ppm   = -[ 2.9  1.0  1.9  1.3  0.0  1.8  1.9  1.3  2.6 ]
       end
       fp = mod_fp(fp);
%---------------------------------------------------------------------------    
     case 'j1v2_beta'
% ONLY SW changed from 'j1v2'       
       switch band
         case 'LW'
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [14.7  41.8  -36.8  -52.2 0 -26.1 36.8  -146.2  73.6];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;
           
           fp.d = [-601 -22  99];
% Shift differences from TVAC 
           fp.d2 = [91.6 78.0 0];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[7.0 3.9 4.4 3.3 0 3.2 5.1 2.9 7.2];

         case 'MW'  % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-11.0  31.3  0  0  0  -31.3  3.7  -5.2  11.0];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-658 -10 -25];
% Shift differences from TVAC 
           fp.d2 = [ 84.6  16.8 0];
           fp.d = fp.d + fp.d2;
           
% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[2.6  1.5 1.6 0.8 0 -0.1 1.8 0.4 3.5];

         case 'SW' % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-40.5  73.1  -18.4  41.8  0  31.3  -7.4  36.5  -25.8];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-605  6  -63] + [25  -60 0];
% Shift differences from TVAC 
           fp.d2 = [ 87.5 -68.7 0];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[2.2 0.8 1.0 1.7 0 1.5 0.9 1.2 2.1];
           fp.ppm2 = -[0.9 0.6 1.5 -0.7 0 0.1 -2.2 -1.1 -0.7];
           fp.ppm = fp.ppm + fp.ppm2;

       end
       fp = mod_fp(fp);
%---------------------------------------------------------------------------    
     case 'j1v2'
       switch band
         case 'LW'
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [14.7  41.8  -36.8  -52.2 0 -26.1 36.8  -146.2  73.6];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;
           
           fp.d = [-601 -22  99];
% Shift differences from TVAC 
           fp.d2 = [91.6 78.0 0];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[7.0 3.9 4.4 3.3 0 3.2 5.1 2.9 7.2];

         case 'MW'  % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-11.0  31.3  0  0  0  -31.3  3.7  -5.2  11.0];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-658 -10 -25];
% Shift differences from TVAC 
           fp.d2 = [ 84.6  16.8 0];
           fp.d = fp.d + fp.d2;
           
% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[2.6  1.5 1.6 0.8 0 -0.1 1.8 0.4 3.5];

         case 'SW' % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-40.5  73.1  -18.4  41.8  0  31.3  -7.4  36.5  -25.8];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-605  6  -63];
% Shift differences from TVAC 
           fp.d2 = [ 87.5 -68.7 0];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[2.2 0.8 1.0 1.7 0 1.5 0.9 1.2 2.1];

       end
       fp = mod_fp(fp);
%---------------------------------------------------------------------------         
     case 'j1v1'
       switch band
         case 'LW'
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [14.7  41.8  -36.8  -52.2 0 -26.1 36.8  -146.2  73.6];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;
           
           fp.d = [-601 -22  99];
% Shift differences from TVAC 
           fp.d2 = [ 0 0 0];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = [0 0 0 0 0 0 0 0 0];

         case 'MW'  % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-11.0  31.3  0  0  0  -31.3  3.7  -5.2  11.0];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-658 -10 -25];
% Shift differences from TVAC 
           fp.d2 = [ 0 0 0];
           fp.d = fp.d + fp.d2;
           
% If needed (if used, don't use fp.dfoax)
           fp.ppm = [0 0 0 0 0 0 0 0 0];

         case 'SW' % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-40.5  73.1  -18.4  41.8  0  31.3  -7.4  36.5  -25.8];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-605  6  -63];
% Shift differences from TVAC 
           fp.d2 = [ 0 0 0];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = [0 0 0 0 0 0 0 0 0];

       end
       fp = mod_fp(fp);
       %--------------------------------------------------------------    
     case 'default'
       fp.s = sdef;
       fp.d = [0 0 0];
       fp.ppm = zeros(1,9);
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
       fp = mod_fp(fp);
       %--------------------------------------------------------------  
     case 'umbc2'
       switch band
         case 'LW'
           fp.s = sdef;
           dnew = [5 9 99];  % add these to umbc1
% From umbc1 MN LW (after r fit)
           fp.ppm = [0.4 0.8 -1.0 -1.0 0 -0.5 1.0 -2.8 2.0];
           fp.d = [-606 -31 0] + dnew;
         case 'MW'
           fp.s = sdef;
           dnew = [0 22 -25];
           fp.ppm = [-0.3 0.6 0 0 0 -0.6 0.1 -0.1 0.3];
           fp.d = [-658 -32 0] + dnew;
         case 'SW'
           fp.s = sdef;
           dnew = [9 16 -63];
           fp.d = [-614 -10 0] + dnew;
           fp.ppm = [-1.1 1.4 -0.5 0.8 0 0.6 -0.2 0.7 -0.7];
       end
       fp = mod_fp(fp);
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
         case 'MW'  % NO CHANGE: == UMBC2
           fp.s = sdef;
           dnew = [0 22 -25];
           fp.ppm = [-0.3 0.6 0 0 0 -0.6 0.1 -0.1 0.3];
           fp.d = [-658 -32 0] + dnew;

           fp.d = [0 0 0];
         case 'SW' % NO CHANGE: == UMBC2
           fp.s = sdef;
           dnew = [9 16 -63];
           fp.d = [-614 -10 0] + dnew;
           fp.ppm = [-1.1 1.4 -0.5 0.8 0 0.6 -0.2 0.7 -0.7];
       end
       fp = mod_fp(fp);
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
           fp.d = [-516  91  0];
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
           fp.d = [-582  0  0];
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
           fp.d = [-578  13  0];
       end
       fp.ppm = zeros(1,9);
       fp = mod_fp(fp);
       %--------------------------------------------------------------  
     case 'j1v2_junk'
       switch band
         case 'LW'
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [14.7  41.8  -36.8  -52.2 0 -26.1 36.8  -146.2  73.6];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;
           
           fp.d = [-601 -22  99];
% Shift differences from TVAC 
%        fp.d2 = [ 85.7 77.2 -227];
%        fp.d2 = [ 85.78 77.2 -326];
           fp.d2 = [ 91.57 78.02 0];
           fp.d = fp.d + fp.d2
           fp.ppm = zeros(1,9);
% below is just forcing fp to equal lw.foax
%withr        fp.ppm = [  1.84          2.31          4.28          2.90             0          2.92          3.62          3.10          1.51];
           fp.ppm = -[  7.01          3.87          4.44          3.33             0          3.18          5.15           2.95          7.20        ];
%         fp.ppm = -[0.85 -0.41 -1.59 -1.01 0 -1.02 -0.94 -1.20 1.18];
%good?        fp.ppm = -[0.93  0.52 -1.42 -0.12 0 -0.04 -0.90 -0.37 1.38];
%        fp.ppm = -[1.3 0.1 -1.1 -0.6 0 -0.5 -0.6 -0.8 1.7]+0.6;
           fp = mod_fp(fp);
         case 'MW'  % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-11.0  31.3  0  0  0  -31.3  3.7  -5.2  11.0];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-658 -10 -25];
% Shift differences from TVAC 
           fp.d2 = [ 82.7 16.6 -95.7];
           fp.d = fp.d + fp.d2;
           
% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[ 0.6 0.3 -0.4 -0.5 0 -1.4 0.4 -0.9 2.2]+0.6;
           fp = mod_fp(fp);
         case 'SW' % NO CHANGE: == UMBC2
           fp.s = sdef;
% fp.ds is umbc2_foax (w/o x,y offset) - default_foax
           fp.dfoax = [-40.5  73.1  -18.4  41.8  0  31.3  -7.4  36.5  -25.8];
% If needed (if used, don't use fp.ppm)
           dfoax2 = [ 0 0 0 0 0 0 0 0 0];
           fp.dfoax = fp.dfoax + dfoax2;

           fp.d = [-605  6  -63];
% Shift differences from TVAC 
           fp.d2 = [ 85.8 -68.5  -55.3 ];
           fp.d = fp.d + fp.d2;

% If needed (if used, don't use fp.dfoax)
           fp.ppm = -[0.6 -0.4 -0.6 0.5 -0.1 0.3 -0.8 0.0 0.5]-0.17;

           fp = mod_fp(fp);
       end
   end
end
%--------------------------------------------------------------  
function fp = mod_fp(fp);
   dr = fp.d(3)
% s(:,2) == y
% s(:,3) == x
   fpang = atan2(fp.s(:,2),fp.s(:,3));
   id = [1:4 6:9];  % FOV5 angle no good and not needed
   fp.s(id,3) = fp.s(id,3) + dr.*cos(fpang(id));
   fp.s(id,2) = fp.s(id,2) + dr.*sin(fpang(id));
% Now have to add in FOV by FOV changes that a single dr can't fix These
% might change once we have J1 data.  They are not quite right for NPP but
% I'm not going to worry about that right now.  Note that if they are
% changed, these changes in theory are only to be used with "j1vn"
   c     = -1/36.8;
   s     = -1/52.2;
   alpha = [ c s c s 0 s c s c];

% J1 override, using FP jacs from Howard's double difference (MAKES NO DIFFERENCE)
   inv_alpha = [ -36.80  -52.20  -36.80   -52.20   Inf   -52.20  -36.80   -52.20   -36.80];
   alpha = 1./inv_alpha;

% This is individual dr, starting with fp.ppm (ppm units)
   dr = -(fp.ppm./alpha)'; % Got the minus wrong for a long time!!
   dr(5) = 0;  % So, no id needed here
   fp.s(:,3) = fp.s(:,3) + dr.*cos(fpang(:));
   fp.s(:,2) = fp.s(:,2) + dr.*sin(fpang(:));
% Compute foax (all needed for ccast, in ccast units)
   fp.foax = sqrt( (fp.s(:,3) + fp.d(2)).^2 + (fp.s(:,2) + fp.d(1)).^2);
   if isfield(fp,'dfoax')
      fp.foax = fp.foax + fp.dfoax';
   end
   fp.foax = 1E-6*fp.foax;  % compatible with ccast
end
%--------------------------------------------------------------  
