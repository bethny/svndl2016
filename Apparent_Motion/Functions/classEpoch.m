function cycleAvg = classEpoch(sampRate,epochT,rawDataBTN,rawDataEEG)
    %% constants
    
    numTrial = size(rawDataBTN,2); % 10
    numCond = size(rawDataBTN,3); % 5
    numTimept = floor(sampRate*epochT); % 216 per epoch? ? ? 
    numEpoch = size(rawDataBTN,1)/numTimept; % 120 per 60-s trial NO MATTER WHAT
    numEpochTotal = numEpoch*numTrial; % 1200
    numStates = 3;
    numChan = size(rawDataEEG,2); % 5

    % concatenating over trials
            
    timeConcatBTN = reshape(rawDataBTN,size(rawDataBTN,1)*numTrial,numCond); % timepts, cond; cond 1 3 4 5 should be HALF NANS; they are
    rearrangedEEG = permute(rawDataEEG,[1,3,4,2]); % switching the order of dimensions so we can easily concatenate over trials
    timeConcatEEG = reshape(rearrangedEEG,size(rearrangedEEG,1)*numTrial,numCond,numChan);
    
    % indexing ??
    
    BTNIdx = nan(size(timeConcatBTN));
    BTNIdx(timeConcatBTN < -3e3) = -1;
    BTNIdx(timeConcatBTN > -3e3 & timeConcatBTN < 3e3) = 0;
    BTNIdx(timeConcatBTN > 3e3) = 1;
    
    epochIdx = repmat(1:numEpochTotal,numTimept,1);
    epochIdx = epochIdx(1:end);
    epochIdx = epochIdx';
    
    %% classifying epochs
    
    for c = 1:numCond
        for e = 1:numEpochTotal
            curIdx = BTNIdx(epochIdx == e,c); % first divide BTNIdx by epoch; working index
                % curIdx = all the timepts that belong to that epoch
            pos = size(find(curIdx == 1),1)/numTimept; % percentage of positive responses IN THAT EPOCH
            zero = size(find(curIdx == 0),1)/numTimept;
            neg = size(find(curIdx == -1),1)/numTimept;
            if pos >= .75
                classifiedEpoch(e,c) = 1; % 1200 x 5 array that contains decisions for each epoch
            else
            end
            if zero >= .75
                classifiedEpoch(e,c) = 0;
            else
            end
            if neg >= .75
                classifiedEpoch(e,c) = -1;
            else
            end
        end
    end
    
    for c = [1,3,4,5]
        classifiedEpoch(numEpochTotal/2+1:end,c) = nan;
    end
    
    %% more indexing
    
    for c = 1:numCond-2
        posEpoch{:,c} = find(classifiedEpoch(:,c) == 1); % index of positive epochs per condition
        zeroEpoch{:,c} = find(classifiedEpoch(:,c) == 0); % use as INDICES 
        negEpoch{:,c} = find(classifiedEpoch(:,c) == -1); 
    end
   
    epochsEEG = reshape(timeConcatEEG,numTimept,numEpochTotal,numCond,numChan);

    % sorting EEG epochs
    
    for c = 1:numCond-2
        posEEG{c} = squeeze(epochsEEG(:,posEpoch{c},c,:));
        zeroEEG{c} = squeeze(epochsEEG(:,zeroEpoch{c},c,:));
        negEEG{c} = squeeze(epochsEEG(:,negEpoch{c},c,:));
        posEEGAvg{c} = squeeze(mean(posEEG{c},2));
        zeroEEGAvg{c} = squeeze(mean(zeroEEG{c},2));
        negEEGAvg{c} = squeeze(mean(negEEG{c},2));
    end
    
    % check if those averages came out right
    figure

    for c = 4:5
        singleAvg{c-3} = squeeze(nanmean(epochsEEG(:,:,c,:),2));
    end
    
    for h = 1:numChan
        subplot(5,5,5*h-4)
            plot(negEEGAvg{1}(:,h),'color','b')
            title(sprintf('AM, minExtreme, Ch %d',h))
            ax = gca;
            ax.XTick = linspace(0,numTimept,6);
            ax.XTickLabel = {'500','100','200','300','400'};
            ylabel('Potential (V)')
            xlabel('Time (ms)')
            axis([0 216 -500 500])
        subplot(5,5,5*h-3)
            plot(posEEGAvg{2}(:,h),'color','r')
            hold on
            plot(negEEGAvg{2}(:,h),'color','b')
            hold off
            title(sprintf('AM, FLA bistable, Ch %d',h))
%             labels = {'FLA','AM'};
%             legend(labels)
            ax = gca;
            ax.XTick = linspace(0,numTimept,6);
            ax.XTickLabel = {'500','100','200','300','400'};
            axis([0 216 -500 500])
        subplot(5,5,5*h-2)
            plot(posEEGAvg{3}(:,h),'color','r')
            title(sprintf('FLA, maxExtreme, Ch %d',h))
            ax = gca;
            ax.XTick = linspace(0,numTimept,6);
            ax.XTickLabel = {'500','100','200','300','400'};
            axis([0 216 -500 500])
        subplot(5,5,5*h-1)
            plot(singleAvg{1}(:,h),'color','r')
            title(sprintf('FLA, Left Patch, Ch %d',h))
            ax = gca;
            ax.XTick = linspace(0,numTimept,6);
            ax.XTickLabel = {'500','100','200','300','400'};
            axis([0 216 -500 500])
        subplot(5,5,5*h)
            plot(singleAvg{2}(:,h),'color','r')
            title(sprintf('FLA, Right Patch, Ch %d',h))
            ax = gca;
            ax.XTick = linspace(0,numTimept,6);
            ax.XTickLabel = {'500','100','200','300','400'};
            axis([0 216 -500 500])
    end

        %% testing classifiedBTN
    close all
    for c = 1:numCond
        subplot(5,2,-1+2*c)
        plot(timeConcatBTN(:,c))
        subplot(5,2,2*c)   
        plot(BTNIdx(:,c))
    end
        figure
    for c = 1:numCond
        subplot(5,1,c)
        plot(classifiedEpoch(:,c))
    end
    
end