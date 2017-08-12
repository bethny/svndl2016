function [pCut, realFreqCut] = temp2spec(Fs, timeConcat, pwr, cutIdx) 

% Fs: 1x1 double array; sampling rate
% timeConcat: raw temporal phase data
% cutIdx: where you want to cut the frequencies

numCon = size(timeConcat,3);
numChan = size(timeConcat,2);

N = size(timeConcat,1);
T = N/Fs;
t = [0:N-1]/N;
realFreq = (0:(N-1))*Fs/N;

if nargin < 3
    fIdx = find(realFreq>0,1):size(realFreq);
else
    fIdx = find(realFreq>0,1):find(realFreq>=cutIdx,1);
end

p = abs(fft(timeConcat))/(N/2);
if pwr == true
    p = p.^2;
else
end
pCut = p(fIdx,:,:);
realFreqCut = realFreq(fIdx);

end 
