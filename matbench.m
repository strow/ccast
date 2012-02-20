
% demo of loops vs array ops

m = 600;
t = 600;
n = 600;
a = rand(m,t);
b = rand(t,n);
d = zeros(m,n);
e = zeros(m,n);

tic
c = a * b;
t1 = toc;

tic
for i = 1 : m
  for j = 1 : n
    for k = 1 : t
      d(i,j) = d(i,j) + a(i,k) * b(k,j);
    end
  end
end    
t2 = toc;

% array op speedup
t2 / t1

tic
for i = 1 : m
  for j = 1 : n
    e(i,j) = a(i,:) * b(:,j);
  end
end
t3 = toc;

% array op speedup
t3 / t1

