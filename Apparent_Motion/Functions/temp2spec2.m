function [pCut, realFreqCut] = temp2spec2(sampRate, avgedEpoch, power, cutIdx) 

    numTimept = size(avgedEpoch,1);
%     T = numTimept/sampRate;
%     t = [0:numTimept-1]/numTimept;
    realFreq = (0:(numTimept-1))*sampRate/numTimept;
    
    if nargin < 4
        cutIdx = realFreq(numTimept/2+1);
    else
    end
    
    fIdx = find(realFreq>0,1):find(realFreq>=cutIdx,1);
    p = abs(fft(avgedEpoch))/(numTimept/2);
    if power == true;
        p = p.^2;
    else
    end
    pCut = p(fIdx,:,:,:);
    realFreqCut = realFreq(fIdx);
    
end