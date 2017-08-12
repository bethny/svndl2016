function [checkedDataEEG] = epochCheck(filePaths_raw, rawData, channels, tempRaw, cycleStartEEG, cycleEnd)
    IsEpochOK_struct = load(filePaths_raw{1},'IsEpochOK');
    IsEpochOK = IsEpochOK_struct.IsEpochOK;
    rawData_128 = double(tempRaw(:, channels));
    
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

    checkedData = reshape(checkedEpoch,size(rawData_128,1),[]);
    checkedDataEEG = checkedData(cycleStartEEG+1:(end-cycleEnd),:); 
    
end