function [data,avgPeakIdx] = pickTimepoints_binary(x,x_128)
% for L/R (single patch) and AMB (AM/FLA) conditions
    avgAcrossChan = squeeze(mean(x,2));
    if length(size(avgAcrossChan)) > 2 % 3D: timept AM/FLA halves / mot_subjAvg_split
        for i = 1:2
            if i == 1;
                avgPeak(i) = max(avgAcrossChan(:,i)); 
                avgPeakIdx(i) = find(avgAcrossChan(:,i) == avgPeak(i));
                data(:,i) = x_128(avgPeakIdx(i),:,i)';
            else
                avgPeak(i) = max(avgAcrossChan(:,i)); 
                avgPeakIdx(i) = find(avgAcrossChan(:,i) == avgPeak(i))+105;
                data(:,i) = x_128(avgPeakIdx(i),:,i)';
            end
        end
    else
        
end