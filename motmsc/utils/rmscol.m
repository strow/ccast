%% return rms value for each column of A ( f: m x n -> n )

function B = rmscol(A)

[m,n] = size(A);

B = sum(A .^ 2);	%% row-vector sum of  columns of A

B = sqrt(B) ./ sqrt(m);

