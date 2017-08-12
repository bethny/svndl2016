clear all;
close all;
% codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
codeFolder = '/Volumes/Denali_4D2/BethanyHung/EEG_Data/Functions';
addpath(genpath(codeFolder));

btnOnly = true;
dataSet = '8jun16_Bethany2'; % name of folder containing .mat files
% dataFolder = sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%s', dataSet);
dataFolder = sprintf('/Volumes/Denali_4D2/BethanyHung/EEG_Data/%s', dataSet);
condNames = {'c001','c002','c003','c004','c005','c006','c007','c008','c009'};
trials = [1:10]; % 3 and 8 have an extra 5 trials each...
seg = 2; % seg you want to look at; generally irrelevant, keep at 2
filePaths_raw = cell(length(condNames),length(trials)); 
filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder, seg);
RTseg = load(filePath_seg);
preDur = RTseg(1).CndTiming.preludeDurSec;
postDur = RTseg(1).CndTiming.postludeDurSec;

for c = 1:length(condNames)
    for t = 1:length(trials)
        filePaths_raw(c,t) = {sprintf('%s/Raw_%s_t%03d.mat', dataFolder, condNames{c}, t)};
        if exist(filePaths_raw{c,t},'file') == 2; 
            allData(c,t) = load(filePaths_raw{c,t});
            cycleStart = preDur*allData(c,t).FreqHz; % trial num after prelude  
            cycleEnd = postDur*allData(c,t).FreqHz; % trial num before postlude
%             rawData = nan(size(squeeze(allData(1,1).RawTrial(cycleStart+1:(end-cycleEnd),2))),10,9);
            rawData(:,t,c) = double(allData(c,t).RawTrial(cycleStart+1:(end-cycleEnd), 2)); % int at end controls column you want to look at
        else
            rawData(:,t,c) = nan(size(rawData(:,1,1)));
        end
    end
end

%% PLOT DATA
plotData = false;
for c=1:length(condNames)
    concatData(:,c) = reshape(rawData(:,:,c),size(rawData,1)*size(rawData,2),1);
    %subplot(length(condNames),1,c);
    if plotData == true
        figure;     
        title(sprintf('cond%d',c));
        plot(concatData(:,c));
        hold on
        ylim([-20000,20000]);
        hold off
    end
end

validCon = [1:9];
validCond = {'1','2','3','4','5','6','7','8','9'}; % just to make the table pretty
concatState = percentState(validCon,validCond,concatData);

pairSep = [10,12,14,14.5,15,15.5,16,18,20]; % x axis values
fit = 'logit'; % 'logit' or 'probit'

% Apparent Motion only
[coeffsAM, statsAM, curveAM, thresholdAM] = FitPsycheCurveLogit(pairSep, concatState(:,1), fit); 

figure, scatter(pairSep,concatState(:,1))
hold on
title('2 Hz')
ylabel('Proportion')
xlabel('Pair separation (lambda)')
plot(curveAM(:,1),curveAM(:,2),'LineStyle','--')
legend('AM','AM fit')

thresholdAM

sampRate = allData(1,1).FreqHz;
