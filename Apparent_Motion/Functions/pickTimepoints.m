function [data,avgPeakIdx] = pickTimepoints(x,x_128)
% for single patch L/R (singleZeroed_subjAvg)
    avgAcrossChan = squeeze(mean(x,2));
%     avgPeak = max(avgAcrossChan);
%     avgPeakIdx = find(avgAcrossChan == avgPeak);
%     data = x_128(avgPeakIdx,:)';
    for i = 1:2
        avgPeak(i) = max(avgAcrossChan(:,i)); 
        avgPeakIdx(i) = find(avgAcrossChan(:,i) == avgPeak(i));
        data(:,i) = x_128(avgPeakIdx(i),:,i)';
    end

end