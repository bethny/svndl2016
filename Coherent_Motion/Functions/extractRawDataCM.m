function [untrimmedEEG_Zeroed, percentNaN, sampRate] = extractRawDataCM(dataFolder, filePath_raw, shift, channels)

    if nargin < 4
        channels = 1:128;
    end
    %%
    RTseg = load(sprintf('%s/RTSeg_s002.mat',dataFolder));
    ssnHeader = load(sprintf('%s/SsnHeader_ssn.mat',dataFolder));
    preDur = RTseg(1).CndTiming.preludeDurSec;
    postDur = RTseg(1).CndTiming.postludeDurSec;
    
    if exist(filePath_raw,'file') == 2; 
        sampRate_struct = load(filePath_raw,'FreqHz');
        sampRate = sampRate_struct.FreqHz;
        tempRaw_struct = load(filePath_raw,'RawTrial');
        tempRaw = tempRaw_struct.RawTrial;
        IsEpochOK_struct = load(filePath_raw,'IsEpochOK');
        IsEpochOK = IsEpochOK_struct.IsEpochOK;
        
        cycleStart = preDur*sampRate; % trial num after prelude  
        cycleEnd = postDur*sampRate; % trial num before postlude
        
        rawData_128 = double(tempRaw(:, channels)); % [1260 128] 
        rawDataShifted = rawData_128(ceil(sampRate*shift):end,:); % [1050 128]; takes 2nd half of the prelude as well
        
        numEpochs = size(IsEpochOK,1);  % 3
        totalTimepts = length(rawData_128); % 1260
        numChannels = size(IsEpochOK,2);    % 128
        timeptsPerEpoch = totalTimepts/numEpochs;
        
        % now to check for IsEpochOk
        checkedEpoch = reshape(rawData_128,timeptsPerEpoch,numEpochs,[]);
        for i = 1:numEpochs % looping over all 24 epochs
            for c = 1:numChannels % looping over all 128 channels
                if IsEpochOK(i,c) == 0
                    checkedEpoch(:,i,c) = nan;
                end
            end
        end
        
        untrimmedEEG = reshape(checkedEpoch,size(rawData_128,1),[]); % [1260 128]; filtered for epochs
        trimmedEEG = untrimmedEEG(cycleStart+1:end,:); % first 500 ms removed
        
        % BASELINING
        subtraction = nanmean(untrimmedEEG(ceil(0.7*sampRate):ceil(sampRate),:),1);
        checked_mean = repmat(subtraction,size(untrimmedEEG,1),1);
        untrimmedEEG_Zeroed = untrimmedEEG - checked_mean;
               
        nan_counter = 0;
        for t = 1:size(untrimmedEEG_Zeroed,1)
            for c = 1:length(channels)
                if isnan(untrimmedEEG_Zeroed(t,c))
                    nan_counter = 1 + nan_counter;
                end
            end
        end
        percentNaN = nan_counter/(size(untrimmedEEG_Zeroed,1)*length(channels));
        
    else
        rawData_128 = nan(1260,1);
        rawDataShifted = nan(1050,1);
        untrimmedEEG = nan(1260,128);
        untrimmedEEG_Zeroed = nan(1260,128);
        percentNaN = 0;
    end
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

