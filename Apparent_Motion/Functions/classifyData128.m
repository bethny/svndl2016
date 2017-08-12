function [posZeroed,negZeroed,singleZeroed,actualZero] = classifyData128(rawDataBTN_1,checkedDES_selected_1,sampRate,epochT,c,singleZeroed)
    % start checking from here
    
    numChan = size(checkedDES_selected_1,2); % 5
    numTimept = floor(sampRate*epochT); % 210 per epoch
    numEpoch = length(rawDataBTN_1)/numTimept; % 120 per 60-s trial NO MATTER WHAT
                                                   
    epochsEEG = reshape(checkedDES_selected_1,numTimept,numEpoch,numChan); % 210 120 5

    if c == 2       % only for ambig condition
        % indexing 
        BTNIdx = nan(size(rawDataBTN_1));
        BTNIdx(rawDataBTN_1 < -3e3) = -1;
        BTNIdx(rawDataBTN_1 > -3e3 & rawDataBTN_1 < 3e3) = 0;
        BTNIdx(rawDataBTN_1 > 3e3) = 1;

        epochIdx = repmat(1:numEpoch,numTimept,1);
        epochIdx = epochIdx(1:end);
        epochIdx = epochIdx';

        for e = 1:numEpoch
            curIdx = BTNIdx(epochIdx == e); % first divide BTNIdx by epoch; working index
                % curIdx = all the timepts that belong to that epoch
            pos = size(find(curIdx == 1),1)/numTimept; % percentage of positive responses IN THAT EPOCH
            zero = size(find(curIdx == 0),1)/numTimept;
            neg = size(find(curIdx == -1),1)/numTimept;
            if pos >= .75
                classifiedEpoch(e) = 1; % 120 x 1 array that contains decisions for each epoch
            else
            end
            if zero >= .75
                classifiedEpoch(e) = 0;
            else
            end
            if neg >= .75
                classifiedEpoch(e) = -1;  
            else
            end
        end
        classifiedEpoch = classifiedEpoch';

        % more indexing
        posEpoch{:} = find(classifiedEpoch == 1); % index of positive epochs per condition
        zeroEpoch{:} = find(classifiedEpoch == 0); 
        negEpoch{:} = find(classifiedEpoch == -1);

        % sorting EEG epochs
        posEEG = epochsEEG(:,posEpoch{:},:);
        zeroEEG = epochsEEG(:,zeroEpoch{:},:);
        negEEG = epochsEEG(:,negEpoch{:},:);
        
        zeroNanCount = 0;
        for n = 1:numTimept
            for e = 1:size(zeroEEG,2) % epochs
                for s = 1:size(zeroEEG,3) % channels
                    if isnan(zeroEEG(n,e,s))
                        zeroNanCount = zeroNanCount + 1;
                    end
                end
            end
        end
        actualZero = numTimept*size(zeroEEG,2)*size(zeroEEG,3) - zeroNanCount; % more timepts lost... 

        posEEGAvg = squeeze(nanmean(posEEG,2)); % if you don't want to zero, use this as pos/negZeroed
        negEEGAvg = squeeze(nanmean(negEEG,2));

        % zero
        pos_mean = repmat(nanmean(posEEGAvg),size(posEEGAvg,1),1);
        posZeroed = posEEGAvg - pos_mean;

        neg_mean = repmat(nanmean(negEEGAvg),size(negEEGAvg,1),1);
        negZeroed = negEEGAvg - neg_mean;
        
        singleZeroed = [];
    
    else
        singleAvg = squeeze(nanmean(epochsEEG,2)); % if you don't want to zero, use this as singleZeroed
        singleAvg_mean = nanmean(singleAvg);
        single_mean = repmat(singleAvg_mean,numTimept,1);
        singleZeroed_pre = singleAvg - single_mean; 
        posZeroed = [];
        negZeroed = [];
        actualZero = [];
        
        if c == 1
            singleZeroed(:,:,1) = singleZeroed_pre;  
        else
            singleZeroed(:,:,2) = singleZeroed_pre;
        end
        
    end
 
end

%% archaic code
%     numEpochTotal = numEpoch*numTrial; % 1920

    % concatenating over trials
%     timeConcatBTN = reshape(rawDataBTN,size(rawDataBTN,1)*numTrial,numCond);                                                                    % 403200 3
%     rearrangedEEG = permute(checkedDES_selected,[1,3,4,2]); % switching the order of dimensions so we can easily concatenate over trials        % 25200  16   3 5
%     timeConcatEEG = reshape(rearrangedEEG,size(rearrangedEEG,1)*numTrial,numCond,numChan);  