function [electrode_sums] = electrodeVector(rawDataEEG_128,trialROI,baseChannel,subjIdx,timeptROI,epochT)

    numTrial = size(rawDataEEG_128,3); % 16
    numCond = size(rawDataEEG_128,4); % 3
    numSubj = size(rawDataEEG_128,5); % 6
    numChan = 128; 
    
    numTimept = floor(sampRate*epochT); % 210 per epoch
    numEpoch = size(rawDataEEG_128,1)/numTimept; % 120 per 60-s trial NO MATTER WHAT
    numEpochTotal = numEpoch*numTrial; % 1920
    
    trialAvgEEG = squeeze(nanmean(rawDataEEG_128,3));
    trialAvgEEG_128 = trialAvgEEG(:,1:128,:,:); % averaged over all trials; size = 25200 128 3 6; cycles channels conditions subjects
    epochsEEG = reshape(trialAvgEEG_128,numTimept,numEpoch,numChan,numCond,numSubj);
    epochsAvg_128 = squeeze(nanmean(epochsEEG,2));
    
    plot(epochsAvg_128(:,1,1,1))
    hold on
    plot(epochsAvg_128(:,70,1,1))
    plot(epochsAvg_128(:,65,1,1))
    
end