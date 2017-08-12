function [rawDataBTN_1, checkedDataEEG_Zeroed, percentNaN] = extractRawData(dataFolder, filePaths_raw, channels, filePath_seg, shift)

    ssnHeader = load(sprintf('%s/SsnHeader_ssn.mat',dataFolder));
    RTseg = load(filePath_seg);
    preDur = RTseg(1).CndTiming.preludeDurSec;
    postDur = RTseg(1).CndTiming.postludeDurSec;
    
    if exist(filePaths_raw{1},'file') == 2; 
        sampRate_struct = load(filePaths_raw{1},'FreqHz');
        sampRate = sampRate_struct.FreqHz;
        tempRaw_struct = load(filePaths_raw{1},'RawTrial');
        tempRaw = tempRaw_struct.RawTrial;
        IsEpochOK_struct = load(filePaths_raw{1},'IsEpochOK');
        IsEpochOK = IsEpochOK_struct.IsEpochOK;
        
        cycleStartBTN = ceil((preDur-0.5)*sampRate);
        cycleStartEEG = preDur*sampRate; % trial num after prelude  
        cycleEnd = postDur*sampRate; % trial num before postlude
        
        rawData = double(tempRaw(:, size(ssnHeader.Montage,1))); % ONLY FOR BTN / [30240 1] / [26040 1] for 1119+
        rawData_128 = double(tempRaw(:, channels)); % ONLY FOR EEG / [26040 128] / hold EEG constant as you shift the buttons to account for pre-decision neural activity 
        rawDataShifted = rawData(ceil(sampRate*shift):end); % first 500 ms of data discarded / [25830 1]
        rawDataBTN_1 = rawDataShifted(cycleStartBTN+1:(end-cycleEnd)); % 500ms shifted & pre/postlude discarded / [25200 1]
        
        numEpochs = size(IsEpochOK,1);
        totalTimepts = length(rawData);
        numChannels = size(IsEpochOK,2);
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
        
        checkedData = reshape(checkedEpoch,size(rawData_128,1),[]); % back to full length & no epoch divisions
        checkedDataEEG = checkedData(cycleStartEEG+1:(end-cycleEnd),:); % pre/postlude trimmed
        
        checked_mean = repmat(nanmean(checkedDataEEG,1),size(checkedDataEEG,1),1);
        checkedDataEEG_Zeroed = checkedDataEEG - checked_mean;
        
        nan_counter = 0;
        for t = 1:size(checkedDataEEG_Zeroed,1)
            for c = 1:length(channels)
                if isnan(checkedDataEEG_Zeroed(t,c))
                    nan_counter = 1 + nan_counter;
                end
            end
        end
        percentNaN = nan_counter/(size(checkedDataEEG_Zeroed,1)*length(channels));
        
    else
        rawData = nan(30240,1);
        rawDataShifted = nan(30030,1);
        rawDataBTN_1 = nan(25200,1);
        checkedDataEEG = nan(25200,128);
        checkedDataEEG_Zeroed = nan(25200,128);
        percentNaN = 0;
    end
   
end