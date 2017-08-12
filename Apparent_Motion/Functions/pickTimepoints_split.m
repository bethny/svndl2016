function [data,avgPeakIdx] = pickTimepoints_split(x,x_128)
% for AMB (AM/FLA) conditions
    avgAcrossChan = squeeze(mean(x,2));
    if length(size(avgAcrossChan)) > 2 % 3D: timept AM/FLA halves / mot_subjAvg_split
        for m = 1:2 % type of motion percept (AM/FLA; 2nd dim) 
            for h = 1:2 % half 1 or half 2
                avgPeak(m,h) = max(avgAcrossChan(:,m,h));
                if h == 1
                    avgPeakIdx(m,h) = find(avgAcrossChan(:,m,h) == avgPeak(m,h));
                else
                    avgPeakIdx(m,h) = find(avgAcrossChan(:,m,h) == avgPeak(m,h))+105;
                end
            end
        end
        avgPeakIdx = ceil(mean(avgPeakIdx,1));
        for m = 1:2
            for h = 1:2
                data(:,m,h) = x_128(avgPeakIdx(m),:,h);
            end
        end

    else % sum_subjAvg
        for h = 1:2
            avgPeak(h) = max(avgAcrossChan(:,h));
            if h == 1
                avgPeakIdx(h) = find(avgAcrossChan(:,h) == avgPeak(h));
            else
                avgPeakIdx(h) = find(avgAcrossChan(:,h) == avgPeak(h))+105;
            end
            data(:,h) = x_128(avgPeakIdx(h),:);
        end
    end
end