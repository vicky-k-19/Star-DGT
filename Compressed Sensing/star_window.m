function v=sic2(L)
%This function implements the power iteration method, which 
%yields the largest in magnitude eigenvalue and  corresponding eigenvector
%of the Zauner unitary matrix. This eigenvector constitutes the star window vector.

%The following formula is equivalent to the one written in the corresponding paper,
%but it is implemented much faster.
binv = L-1; d=binv; a=0;
u = 0:L-1;
summa = 1i*(pi/6 + (pi/L+pi)*binv*d*u.^2);
delta = exp(summa)/sqrt(L);
D = spdiag(delta);

Ugz=@(v) D*fft(v); 

%Calculate the desired window vector
v = randn(L,1);
lambda = inf;
tol = 100*eps;
lambdaold = 1;
while abs(lambda - lambdaold) > tol
  lambdaold = lambda;
  vnew = Ugz(v);
  lambda = norm(vnew)/norm(v);
  v = vnew/max(abs(vnew));
end
