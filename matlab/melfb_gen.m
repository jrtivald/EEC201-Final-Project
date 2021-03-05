function m = melfb_gen(p,n,fs)
% MELFB_GEN Generate a mel-spaced filterbank matrix
%
% USAGE: m = melfb_gen(p,n,fs)
%
% INPUTS: 
%   p = number of filter in filter bank
%   n = fft length
%   fs = sample rate in hertz
%
% OUTPUTS:
%   m = matrix containing filterbank magnitudes. The size of m is 
%   [p,1+floor(n/2)].

f0 = 700 / fs; 
fn2 = floor(n/2);
Lr = log(1 + 0.5/f0) / (p+1);

% convert to fft bin numbers with 0 for DC term
Bv = n*(f0*(exp([0 1 p p+1]*Lr) - 1));

b1 = floor(Bv(1)) + 1; 
b2 = ceil(Bv(2));
b3 = floor(Bv(3)); 
b4 = min(fn2, ceil(Bv(4))) - 1;

pf = log(1 + (b1:b4)/n/f0) / Lr; fp = floor(pf);
pm = pf - fp;

r = [fp(b2:b4) 1+fp(1:b3)];
c = [b2:b4 1:b3] + 1;
v = 2 * [1-pm(b2:b4) pm(1:b3)];

m = sparse(r, c, v, p, 1+fn2);

end

