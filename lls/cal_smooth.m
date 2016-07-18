function sm = cal_smooth(cal,ctype,csize);

for j=1:csize
   for k=1:9
      kstart = 1;
      kstop = 0;
      sig = [];
      for i=1:length(cal)
         sig = [sig squeeze(cal(i).(ctype)(j,k,:,:))];
         n = length(cal(i).FORTime);
         kstop = kstop + n;
         ncal(i).ind = kstart:kstop;
         kstart = kstop + 1;
      end
      s1 = smooth(sig(1,:),31,'moving');
      s2 = smooth(sig(2,:),31,'moving');
      for i=1:length(cal)
         sm(i).(ctype)(j,k,1,:) = s1(ncal(i).ind);
         sm(i).(ctype)(j,k,2,:) = s2(ncal(i).ind);
      end
   end
end
