function [rawDataBTN, rawDataEEG] = extractRawData(dataFolder, filePaths_raw, preDur, postDur, shift,t,c,s)

    ssnHeader = load(sprintf('%s/SsnHeader_ssn.mat', dataFolder{1}));
    if exist(filePaths_raw,'file') == 2; 
        sampRate_struct = load(filePaths_raw{1,1,1},'FreqHz');
        sampRate = sampRate_struct.FreqHz;
        tempRaw_struct = load(filePaths_raw,'RawTrial');
        tempRaw = tempRaw_struct.RawTrial;
        cycleStartBTN = ceil((preDur-0.5)*sampRate);
        cycleStartEEG = preDur*sampRate; % trial num after prelude  
        cycleEnd = postDur*sampRate; % trial num before postlude
        rawData = double(tempRaw(:, size(ssnHeader.Montage,1))); % int at end controls column you want to look at            
        rawDataShifted = rawData(ceil(sampRate*shift):end,t,c,s); % first 500 ms of data discarded
        rawDataBTN = rawDataShifted(cycleStartBTN+1:(end-cycleEnd),t,c,s); % 500ms shifted & pre/postlude discarded
        rawDataEEG = double(tempRaw(cycleStartEEG+1:(end-cycleEnd), channels)); 
    else
        rawData = nan(size(rawData(:,1,1,1)));
        rawDataShifted = nan(size(rawDataShifted(:,1,1,1)));
        rawDataBTN = nan(size(rawDataBTN(:,1,1,1)));
        rawDataEEG = nan(size(rawDataEEG(:,:,1,1,1)));
    end
   
end