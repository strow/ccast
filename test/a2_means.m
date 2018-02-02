
d1 = load('a2_set2_1/a2vals');
d2 = load('a2_set2_2/a2vals');
d3 = load('a2_set2_3/a2vals');
d4 = load('a2_set2_4/a2vals');

a2tab = [d1.a2tmpLW, d2.a2tmpLW, d3.a2tmpLW, d4.a2tmpLW];

a2LW = mean(a2tab, 2);

bar(a2LW)
grid on

a2LW
