function [epochsEEG,timeConcatBTN] = cutEpochs(rawDataBTN,rawDataEEG,sampRate,epochT)
    
    numTrial = size(rawDataEEG,3); % 10
    numCond = size(rawDataEEG,4); % 5
    numStates = 3;
    numChan = size(rawDataEEG,2); % 5
    numTimept = floor(sampRate*epochT); % 216 per epoch? ? ? 
    numEpoch = size(rawDataBTN,1)/numTimept; % 120 per 60-s trial NO MATTER WHAT
    numEpochTotal = numEpoch*numTrial; % 1200
    numSubj = size(rawDataBTN,4);
    
    timeConcatBTN = reshape(rawDataBTN,size(rawDataBTN,1)*numTrial,numCond,numSubj); % timepts, cond; cond 1 3 4 5 should be HALF NANS; they are
    rearrangedEEG = permute(rawDataEEG,[1,3,4,2,5]); % switching the order of dimensions so we can easily concatenate over trials
    timeConcatEEG = reshape(rearrangedEEG,size(rearrangedEEG,1)*numTrial,numCond,numChan,numSubj);
    epochsEEG = reshape(timeConcatEEG,numTimept,numEpochTotal,numCond,numChan,numSubj);

end