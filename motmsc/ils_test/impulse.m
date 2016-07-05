
dv = 0.01;
v1 = 600;
v2 = 1200;
n = round((v2 - v1) / dv);
vg = v1 + (0 : n) * dv;

dg = zeros(n, 1);
dg(floor(n/2), 1) = 1;

dv2 = 0.5;
[dg2, vg2] = finterp(dg, vg, dv2, opt);



 
