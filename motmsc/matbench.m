%
% matbench -- simple matlab vectorization demo
% 
% Test 1: compare matrix multiplication times
%   (a) fully vectorized A * B 
%   (b) partly vectorized, with m x n inner products
%   (c) explicit loops, m x n x t scalar multiplys
%
% Test 2: compare elementwise multiplication times
%   (a) fully vectorized A .* B 
%   (b) row order scalar
%   (c) column order scalar
%
% speedup values are sensitive to the timing of the fully vectorized
% product A * B, to check for this just rerun the script a few times
%

% -------------------------------------------
% Test 1: compare matrix multiplication times
% -------------------------------------------
m = 1200; 
t = 1400; 
n = 1200;
A = rand(m,t); 
B = rand(t,n);
C = zeros(m,n);
fprintf(1, 'Test 1: A * B for A = %d x %d, B = %d x %d\n', m, t, t, n)

% --------------------------
% (a) fully vectorized A * B
% --------------------------
tic
C = A * B;
t1 = toc;
D = C;
fprintf(1, '%6.2f sec for fully vectorized A * B\n', t1);

% ----------------------------------------------------
% (b) partly vectorized, m x n length t inner products
% ----------------------------------------------------
C = zeros(m,n);
tic
for i = 1 : m
  for j = 1 : n
    C(i,j) = A(i,:) * B(:,j);
  end
end
t2 = toc;
% max(abs(C(:) - D(:)))
fprintf(1, '%6.2f sec for m x n t-element inner products, %.0f x slower\n', ...
        t2, t2/t1)

% -----------------------------------------------
% (c) explicit loops, m x n x t scalar multiplies
% -----------------------------------------------
C = zeros(m,n);
tic
for i = 1 : m
  Ai = A(i, :);  % save row i of A as a vector
  for j = 1 : n
    for k = 1 : t
      C(i,j) = C(i,j) + Ai(k) * B(k,j);
    end
  end
end    
t3 = toc;
% max(abs(C(:) - D(:)))
fprintf(1, '%6.2f sec for m x n x t scalar multiplies, %.0f x slower\n', ...
        t3, t3/t1)

% ------------------------------------------------
% Test 2: compare elementwise multiplication times
% ------------------------------------------------
n1 = 600; 
n2 = 600; 
n3 = 600;
A = rand(n1, n2, n3);
B = rand(n1, n2, n3);
C = zeros(n1, n2, n3);
fprintf(1, 'Test 2: A .* B for A and B = %d x %d x %d\n', n1, n2, n3)

% ---------------------------
% (a) fully vectorized A .* B
% ---------------------------
tic
C = A .* B;
t1 = toc;
fprintf(1, '%6.2f sec for vectorized A .* B\n', t1)

% --------------------------------------------
% multiply elements of A and B in column order
% --------------------------------------------
tic
for k = 1 : n3
  for j = 1 : n2
    for i = 1 : n1
      C(i, j, k) = A(i, j, k) * B(i, j, k);
    end
  end
end
t2 = toc;
fprintf(1, '%6.2f sec for column order scalar, %.0f x slower\n', t2, t2/t1);

% -----------------------------------------
% multiply elements of A and B in row order
% -----------------------------------------
tic
for i = 1 : n1
  for j = 1 : n2
    for k = 1 : n3
      C(i, j, k) = A(i, j, k) * B(i, j, k);
    end
  end
end
t3 = toc;
fprintf(1, '%6.2f sec for row order scalar, %.0f x slower\n', t3, t3/t1);

