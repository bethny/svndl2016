function [fIdx] = freqCutter(cutIdx)
    s = size(grandAve);
    N = s(1,1);
    realFreq = (0:(N-1))*Fs/N;
    fIdx = find(realFreq>0,1):find(realFreq==cutIdx,1);
end 