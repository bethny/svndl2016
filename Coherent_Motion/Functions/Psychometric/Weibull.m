function y = Weibull(p,x)
%y = Weibull(p,x)
%
%Parameters:  p.b slope
%             p.t threshold yielding ~80% correct
%             p.g chance performance
%             p.e threshold value
%             x   intensity values.

%e = (p.g)^(1/3);  %threshold performance ( ~80%)

%here it is.
k = (-log( (1-p.e)/(1-p.g)))^(1/p.b);
y = 1- (1-p.g)*exp(- (k*x/p.t).^p.b);
