function SNR = SNRcalc(pCut,realFreqCut,freqROI)
% frequency = the one you want a peak at 
% 2 options: 10 or max
% pCut: m x n matrix of spectral values
% frequency: 1 x n array of frequencies matched to pCut, in Hz
% freqIdx: the harmonic for which to compute SNR, in Hz

if nargin < 3
    for c=1:size(pCut,2)
        [powerPeak(c), freqIdx(c)] = max(pCut(:,c));
    end
    [~, tempIdx] = max(powerPeak);
    freqIdx = freqIdx(tempIdx);
else
    freqIdx = find(realFreqCut==freqROI);
end
noiseIdx = [freqIdx-2,freqIdx-1,freqIdx+1,freqIdx+2];

for c = 1:size(pCut,2)
    roiSignal(1,c) = pCut(freqIdx, c); % grabbing y values of surrounding harmonics
    roiNoise(1,c) = nanmean(pCut(noiseIdx, c)); % grabbing y values of surrounding harmonics
    SNR(c) = roiSignal(c)/roiNoise(c);
end
