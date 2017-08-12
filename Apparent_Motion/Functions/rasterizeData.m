function [RGBMat] = rasterizeData(condNames,rawDataBTN,trials)
% Takes EEG data and converts it into RGB values for raster plots

    for c = 1:length(condNames)
        indivCond(c) = {squeeze(rawDataBTN(:,:,c))'};
    end

    numTimepts = size(rawDataBTN,1);
    rasterData = [indivCond{1};indivCond{2}; indivCond{3};indivCond{4};indivCond{5}];

    % just use rawDataBTN as the inputs
    % current size: 25920 10 5, timept trial condition
    % split into conditions then stack those conditions

    for i = 1:length(condNames)*length(trials)
        for j = 1:numTimepts
            if rasterData(i,j) < -0.3e4 % negatives, red
                RGBMat(i,j,1) = 236/255;
                RGBMat(i,j,2) = 74/255;
                RGBMat(i,j,3) = 74/255;
            elseif rasterData(i,j) > -0.3e4 && rasterData(i,j) < 0.3e4 % zeros, orange
                RGBMat(i,j,1) = 249/255;
                RGBMat(i,j,2) = 216/255;
                RGBMat(i,j,3) = 127/255;
            else
                RGBMat(i,j,1) = 123/255;
                RGBMat(i,j,2) = 212/255;
                RGBMat(i,j,3) = 220/255; % positives, blue
            end
        end
    end
end