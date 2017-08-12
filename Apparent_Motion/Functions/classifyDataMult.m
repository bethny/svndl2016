function [posEEGAvg,zeroEEGAvg,negEEGAvg,singleAvg,timeConcatBTN] = classifyDataMult(rawDataBTN,rawDataEEG,sampRate,epochT)

    numTrial = size(rawDataBTN,2); % 10
    numCond = size(rawDataBTN,3); % 5
    numTimept = floor(sampRate*epochT); % 216 per epoch? ? ? 
    numEpoch = size(rawDataBTN,1)/numTimept; % 120 per 60-s trial NO MATTER WHAT
    numEpochTotal = numEpoch*numTrial; % 1200
    numStates = 3;
    numChan = size(rawDataEEG,2); % 5
    numSubj = size(rawDataBTN,4); 
    
%     [epochsEEG,timeConcatBTN,numTrial,numCond,numTimept,numEpoch,numEpochTotal,numStates,numChan] = cutEpochs(rawDataBTN,rawDataEEG,sampRate,epochT);

    % concatenating over trials
    timeConcatBTN = reshape(rawDataBTN,size(rawDataBTN,1)*numTrial,numCond,numSubj); % timepts, cond; cond 1 3 4 5 should be HALF NANS; they are
    rearrangedEEG = permute(rawDataEEG,[1,3,4,2,5]); % switching the order of dimensions so we can easily concatenate over trials
    timeConcatEEG = reshape(rearrangedEEG,size(rearrangedEEG,1)*numTrial,numCond,numChan,numSubj);
    epochsEEG = reshape(timeConcatEEG,numTimept,numEpochTotal,numCond,numChan,numSubj);

    % indexing ??

    BTNIdx = nan(size(timeConcatBTN));
    BTNIdx(timeConcatBTN < -3e3) = -1;
    BTNIdx(timeConcatBTN > -3e3 & timeConcatBTN < 3e3) = 0;
    BTNIdx(timeConcatBTN > 3e3) = 1;

    epochIdx = repmat(1:numEpochTotal,numTimept,1);
    epochIdx = epochIdx(1:end);
    epochIdx = epochIdx';

    % classifying epochs
    for s = 1:numSubj
        for c = 1:numCond
            for e = 1:numEpochTotal
                curIdx = BTNIdx(epochIdx == e,c,s); % first divide BTNIdx by epoch; working index
                    % curIdx = all the timepts that belong to that epoch
                pos = size(find(curIdx == 1),1)/numTimept; % percentage of positive responses IN THAT EPOCH
                zero = size(find(curIdx == 0),1)/numTimept;
                neg = size(find(curIdx == -1),1)/numTimept;
                if pos >= .75
                    classifiedEpoch(e,c,s) = 1; % 1200 x 5 array that contains decisions for each epoch
                else
                end
                if zero >= .75
                    classifiedEpoch(e,c,s) = 0;
                else
                end
                if neg >= .75
                    classifiedEpoch(e,c,s) = -1;
                else
                end
            end
        end
    end

    for c = [1,3,4,5]
        classifiedEpoch(numEpochTotal/2+1:end,c,:) = nan;
    end

    % more indexing

    for c = 1:numCond-2 % -2 because we don't care about the single patch states
        for s = 1:numSubj
            posEpoch{:,c,s} = find(classifiedEpoch(:,c,s) == 1); % index of positive epochs per condition
            zeroEpoch{:,c,s} = find(classifiedEpoch(:,c,s) == 0); % use as INDICES 
            negEpoch{:,c,s} = find(classifiedEpoch(:,c,s) == -1); 
        end
    end

    %% sorting EEG epochs
    for c = 1:numCond-2
        for s = 1:numSubj
            posEEG{c,s} = squeeze(epochsEEG(:,posEpoch{:,c,s},c,:,s));
            zeroEEG{c,s} = squeeze(epochsEEG(:,zeroEpoch{:,c,s},c,:,s));
            negEEG{c,s} = squeeze(epochsEEG(:,negEpoch{:,c,s},c,:,s));
            posEEGAvg{c,s} = squeeze(mean(posEEG{c,s},2));
            zeroEEGAvg{c,s} = squeeze(mean(zeroEEG{c,s},2));
            negEEGAvg{c,s} = squeeze(mean(negEEG{c,s},2));
        end
    end

    %% 
    for c = 4:5
        singleAvg{c-3} = squeeze(nanmean(epochsEEG(:,:,c,:,:),2));
    end

end