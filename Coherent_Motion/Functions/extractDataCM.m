function [EEG_0ed, untrimmedEEG, sampRate] = extractDataCM(dataFolder, filePath, baseline, channels, shift)

    if nargin < 5
        shift = 0;       
    end
    
    if nargin < 4
        channels = 1:128;
    end
    
    if nargin < 3
        baseline = 0.7;
    end
    
    %%
    filePath_complete = sprintf('%s/%s',dataFolder,filePath);
    
    RTseg = load(sprintf('%s/RTSeg_s002.mat',dataFolder));
    ssnHeader = load(sprintf('%s/SsnHeader_ssn.mat',dataFolder));
    preDur = RTseg(1).CndTiming.preludeDurSec;
    postDur = RTseg(1).CndTiming.postludeDurSec;

    all = load(filePath_complete);
    sampRate = all.FreqHz;
    rawData_128 = double(all.RawTrial(:,1:128));
    IsEpochOK = all.IsEpochOK;

    cycleStart = preDur*sampRate; % trial num after prelude  

    if shift ~= 0
        rawDataShifted = rawData_128(floor(sampRate*shift)+1:end,:); % [1050 128]; takes 2nd half of the prelude as well
    end

    numEpochs = size(IsEpochOK,1);  % 3
    totalTimepts = length(rawData_128); % 1260
    numChannels = size(IsEpochOK,2);    % 128
    timeptsPerEpoch = totalTimepts/numEpochs;

    % now to check for IsEpochOk
    checkedEpoch = reshape(rawData_128,timeptsPerEpoch,numEpochs,[]);
    for i = 1:numEpochs % looping over all 3 epochs
        for c = 1:numChannels % looping over all 128 channels
            if IsEpochOK(i,c) == 0
                checkedEpoch(:,i,c) = nan;
            end
        end
    end

    untrimmedEEG = reshape(checkedEpoch,size(rawData_128,1),[]); % [1260 128]; filtered for epochs
    untrimmedEEG = untrimmedEEG(:,channels);
%     trimmedEEG = untrimmedEEG(cycleStart+1:end,:); % first 500 ms removed

    % BASELINING
    if strcmp(baseline,'whole')
        subtraction = nanmean(untrimmedEEG(420:840,:),1);
    else
        subtraction = nanmean(untrimmedEEG(ceil(baseline*sampRate):ceil(sampRate),:),1);
    end
    untrimmedEEG(:,isnan(subtraction))=NaN; % if baselining period is all NaNs, make that whole channel NaNs
    checked_mean = repmat(subtraction,size(untrimmedEEG,1),1);
    EEG_0ed = untrimmedEEG - checked_mean;
        
   %% TESTING
%         channel = 75;
%   
%         x1=[1:420];
%         x2=[421:840];
%         x3=[841:1260];
%         y1=[untrimmedEEG(x1,channel)];
%         y2=[untrimmedEEG(x2,channel)];
%         y3=[untrimmedEEG(x3,channel)];
%         
%         hold on
%         plot(x1,y1,'color','r')
%         plot(x2,y2,'color','b')
%         plot(x3,y3,'color','k')
end

