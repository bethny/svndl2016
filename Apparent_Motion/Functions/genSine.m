function [freq,pNew,fCut,timeCut] = genSine(N, sampRate, amp, freqROI, timeEnd)
% different freqROIs are the different "conditions"
for i = 1:length(freqROI);
    T = N/sampRate;
    t = [0:N-1]/N;
    t = t*T;
    f(:,i) = amp*sin(2*pi*freqROI(i)*t);
    p(:,i) = abs(fft(f(:,i)))/(N/2);
    pNew(:,i) = p(1:N/2,i).^2;
    freq = [0:N/2-1]/T;
    fCut(:,i) = f(1:sampRate*timeEnd,i);
    % cut f
end
timeEnd = 1;
timeCut = linspace(0,timeEnd,length(fCut));
% bar(freq,p)
% set(gca,'XScale','log');
% axis([0 20 0 1])

end