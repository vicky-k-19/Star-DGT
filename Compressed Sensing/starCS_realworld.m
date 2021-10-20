signal=input('Choose real-world signal to test: SI1899, SI1948, SI2141, SI1716, SX5 or SX224: ');

if strcmp(signal,'SI1899')
    L=20349; a=19; b=21;
    [x_original,fs]=audioread('SI1899.wav');
elseif strcmp(signal,'SI1948')
    L=24633; a=21; b=23;
    [x_original,fs]=audioread('SI1948.wav');
elseif strcmp(signal,'SI2141')
    L=21735; a=21; b=23;
    [x_original,fs]=audioread('SI2141.wav');
elseif strcmp(signal,'SI1716')
    L=24633; a=23; b=21;
    [x_original,fs]=audioread('SI1716.wav');
elseif strcmp(signal,'SX5')
    L=23205; a=17; b=13;
    [x_original,fs]=audioread('SX5.wav');
elseif strcmp(signal,'SX224')
    L=24633; a=23; b=21;
    [x_original,fs]=audioread('SX224.wav');
else
    fprint('False signal ID. Choose among SI1899, SI1948, SI2141, SX5, SX224 or SI1716. ');
end

x_original=x_original(1:L);

%Creation of the measurements interval
m=round(linspace(1,L,1000));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

%Creation of the star window vector. We divide it by its 2-norm (which preserves
%the SDGF property) to speed up computations
g=star_window(L); g=g/norm(g);

%Production of the four frames with their corresponding operators 
F1a=frame('dgtreal', g, a, L/b);
W1f= @(x) frana(F1a,x);
W1t=@(x) frsyn(F1a,x);
y1=W1f(x_original); P1=length(y1);
W1=linop_handles([P1,L],W1f,W1t,'R2C');

F2a=frame('dgtreal', 'gauss', a, L/b);
W2f= @(x) frana(F2a,x);
W2t= @(x) frsyn(F2a,x);
y2=W2f(x_original); P2=length(y2);
W2=linop_handles([P2,L],W2f,W2t,'R2C');

F3a=frame('dgtreal','hann',a,L/b);
W3f= @(x) frana(F3a,x);
W3t= @(x) frsyn(F3a,x);
y3=W3f(x_original); P3=length(y3);
W3=linop_handles([P3,L],W3f,W3t,'R2C');

F4a=frame('dgtreal','hamming',a,L/b);
W4f=@(x) frana(F4a,x);
W4t=@(x) frsyn(F4a,x);
y4=W4f(x_original); P4=length(y4);
W4=linop_handles([P4,L],W4f,W4t,'R2C');

%Due to randomness, we perform each experiment 10 times and take the
%average error
iter=10;

if strcmp(signal,'SI1716')
    mu1=norm(y1,Inf);
    mu2=norm(y2,Inf);
    mu3=norm(y3,Inf);
    mu4=norm(y4,Inf);
else
    mu1=1e-1*norm(y1,Inf);
    mu2=1e-1*norm(y2,Inf);
    mu3=1e-1*norm(y3,Inf);
    mu4=1e-1*norm(y4,Inf);
end

meanerror1=zeros(iter,1);
meanerror2=zeros(iter,1);
meanerror3=zeros(iter,1);
meanerror4=zeros(iter,1);

mm1=zeros(length(m),1);
mm2=zeros(length(m),1);
mm3=zeros(length(m),1);
mm4=zeros(length(m),1);

for j=1:length(m)
for i=1:iter
omega = randsample(L,m(j));
omega=omega(1:m(j));
downsample = @(x) x(omega);
SS.type = '()'; SS.subs{1} = omega; SS.subs{2} = ':';
upsample = @(x) subsasgn( zeros(L,size(x,2)),SS,x);

rp = randperm(L);
[~,rp_inv] = sort(rp);
rpF = @(x) x(rp);
rp_invF = @(x) x(rp_inv);

%Setup of measurement matrix
Af = @(x) downsample(rpF(x));
At = @(y) rp_invF(upsample(y));
A = linop_handles([m(j),L], Af, At);

%Calculation of noisy measurements 
y_original=Af(x_original);
sigma = 0.001;
y     = y_original + sigma * randn(size(b_original));
EPS = norm(b-y_original);

x0 = At(y_original);
z0= [];
opts=[];
opts.maxIts     = 3;
opts.tol        = 1e-3;

%Call the solvers
[ x1, out1, optsOut1 ]=solver_sBPDN_W( A, W1, y, EPS, mu1, x0, z0, opts);
[ x2, out2, optsOut2 ]=solver_sBPDN_W( A, W2, y, EPS, mu2, x0, z0, opts);
[ x3, out3, optsOut3 ]=solver_sBPDN_W( A, W3, y, EPS, mu3, x0, z0, opts);
[ x4, out4, optsOut4 ]=solver_sBPDN_W( A, W4, y, EPS, mu4, x0, z0, opts);

meanerror1(i)=norm(x_original-x1)/norm(x_original);
meanerror2(i)=norm(x_original-x2)/norm(x_original);
meanerror3(i)=norm(x_original-x3)/norm(x_original);
meanerror4(i)=norm(x_original-x4)/norm(x_original);
disp(i);
end
mm1(j)=mean(meanerror1);
mm2(j)=mean(meanerror2);
mm3(j)=mean(meanerror3);
mm4(j)=mean(meanerror4);
disp(j);
end

figure
plot(m,mm1,'b--o',m,mm2,'r--*',m,mm3,'m--x',m,mm4,'k--d');
xlim([1 L]);
xlabel('number of measurements K');
ylabel('relative error');
lgd = legend('star','Gaussian','Hann','Hamming','Location','southwest');
title(lgd,'DGTs');
legend('boxoff');
fig=gcf; saveas(fig,'reconstructed TIMIT signal.fig'); saveas(fig,'reconstructed TIMIT signal.jpg');