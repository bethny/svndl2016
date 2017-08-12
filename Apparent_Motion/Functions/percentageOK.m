function [percentOK] = percentageOK(filePaths_raw,channels)

    if exist(filePaths_raw{1},'file') == 2; 
        IsEpochOK_struct = load(filePaths_raw{1},'IsEpochOK');
        IsEpochOK = IsEpochOK_struct.IsEpochOK;
        
        % per channel
        for h = 1:length(channels)
            percentOK(h) = sum(IsEpochOK(:,h))/size(IsEpochOK,1);
            percentOK = percentOK';
        end
        
    else
        percentOK = nan(128,1);
        
    end
    
end
        
        % per condition