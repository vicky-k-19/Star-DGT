%Denoising an example speech signal

N=41769; a=21; b=17;

[x_original,fs]=audioread('2035-147960-0013.flac');
x_original=x_original(1:N);

%Creation of the star window vector. We divide it by its 2-norm (which preserves
%the SDGF property) to speed up computations
g=star_window(L); g=real(g)/norm(g);

%Production of the four frames with their corresponding operators 
F1a=frame('dgtreal', g, a, N/b);
W1f= @(x) frana(F1a,x);
W1t=@(x) frsyn(F1a,x);
y1=W1f(x_original); P1=length(y1);
W1=linop_handles([P1,N],W1f,W1t,'R2C');

F2a=frame('dgtreal', 'gauss', a, N/b);
W2f= @(x) frana(F2a,x);
W2t= @(x) frsyn(F2a,x);
y2=W2f(x_original); P2=length(y2);
W2=linop_handles([P2,N],W2f,W2t,'R2C');

F3a=frame('dgtreal','hann',a,N/b);
W3f= @(x) frana(F3a,x);
W3t= @(x) frsyn(F3a,x);
y3=W3f(x_original); P3=length(y3);
W3=linop_handles([P3,N],W3f,W3t,'R2C');

F4a=frame('dgtreal','hamming',a, N/b);
W4f=@(x) frana(F4a,x);
W4t=@(x) frsyn(F4a,x);
y4=W4f(x_original); P4=length(y4);
W4=linop_handles([P4,N],W4f,W4t,'R2C');

mu1=1e-1*norm(y1,Inf);
mu2=1e-1*norm(y2,Inf);
mu3=1e-1*norm(y3,Inf);
mu4=1e-1*norm(y4,Inf);

sigma=linspace(.001,.01);
mse1=zeros(length(sigma),1);
mse2=zeros(length(sigma),1);
mse3=zeros(length(sigma),1);
mse4=zeros(length(sigma),1);

x0=sparse(N,1);

%Setup of measurement matrix. Since we perform denoising, A is simply the
%identity
A = linop_handles([N,N], @(x) x, @(x) x);

for i=1:length(sigma)

%Generation of blue noise
pink_noise = dsp.ColoredNoise('pink','SamplesPerFrame',N);

%Calculation of noisy measurements
x_noisy = x_original+sigma(i)*pink_noise();
y = x_noisy;
y_original = x_original;
EPS = norm(y-y_original);
        
opts = [];
opts.maxIts     = 3;
opts.tol        = 1e-4;
z0 = [];

%Call the solvers
[xp1,out,optsOut] = solver_sBPDN_W( A, W1, y, EPS, mu1, x0, z0, opts);
[xp2,out,optsOut] = solver_sBPDN_W( A, W2, y, EPS, mu2, x0, z0, opts);
[xp3,out,optsOut] = solver_sBPDN_W( A, W3, y, EPS, mu3, x0, z0, opts);
[xp4,out,optsOut] = solver_sBPDN_W( A, W4, y, EPS, mu4, x0, z0, opts);

mse1(i)=immse(xp1,x_original);
mse2(i)=immse(xp2,x_original);
mse3(i)=immse(xp3,x_original);
mse4(i)=immse(xp4,x_original);
disp(i);
end

figure(1); xlim([0.001 length(sigma)]);
plot(sigma,mse1,'b--o',sigma,mse2,'r--*',sigma,mse3,'m--x',sigma,mse4,'k--d');
xlabel('amplitude of blue noise'); ylabel('MSE$$(x,\hat{x})$$','interpreter','latex');
lgd = legend('star','Gaussian','Hann','Hamming','Location','southeast');
title(lgd,'DGTs');
legend('boxoff');
fig=gcf; saveas(fig,'denoised speech signal.fig'); saveas(fig,'denoised speech signal.jpg');