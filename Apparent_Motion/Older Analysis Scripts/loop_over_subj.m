for c = 1:length(condNames)
    for t = 1:length(trials)
        for s = 1:size(dataSet,2)
            filePaths_raw(t,s,c) = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{s}, c, t)};
            if exist(filePaths_raw{t,s,c},'file') == 2; 
                allData(t,s,c) = load(filePaths_raw{t,s,c});
                sampRate = allData(1,1).FreqHz;
                cycleStart = preDur*allData(1,1,1).FreqHz; % trial num after prelude  
                cycleEnd = postDur*allData(1,1,1).FreqHz; % trial num before postlude
                rawData(:,t,s,c) = double(allData(t,s,c).RawTrial(:, numChan+1)); % int at end controls column you want to look at
                rawDataShifted(:,t,s,c) = rawData(ceil(sampRate*shift):end,t,s,c); % first 500 ms of data discarded
                rawDataBTN(:,t,s,c) = rawData(cycleStart+1:(end-cycleEnd),t,s,c); % 500ms shifted & pre/postlude discarded
                rawDataEEG(:,1:numChan,t,s,c) = double(allData(t,s,c).RawTrial(cycleStart+1:(end-cycleEnd), 1:numChan)); % int at end controls column you want to look at
            else
                rawData(:,t,s,c) = nan([size(rawData(:,1,1,1))]);
                rawDataShifted(:,t,s,c) = nan([size(rawDataShifted(:,1,1,1))]);
                rawDataBTN(:,t,s,c) = nan([size(rawDataBTN(:,1,1,1))]);
                rawDataEEG(:,:,t,s,c) = nan([size(rawDataEEG(:,:,1,1,1))]);
            end
        end
    end
end