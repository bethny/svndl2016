clear all;
close all;
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
% codeFolder = '/Volumes/Denali_4D2/BethanyHung/EEG_Data/Functions';
addpath(genpath(codeFolder));

btnOnly = true;
dataSet = '8jun16_Bethany1'; % name of folder containing .mat files
dataFolder = sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%s', dataSet);
% dataFolder = sprintf('/Volumes/Denali_4D2/BethanyHung/EEG_Data/%s', dataSet);
condNames = {'c001','c002','c003','c004','c005','c006','c007','c008','c009'};
trials = [1:5]; 
seg = 2; % seg you want to look at
filePaths_raw = cell(length(condNames),length(trials)); 

filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder, seg);
RTseg = load(filePath_seg);
preDur = RTseg(1).CndTiming.preludeDurSec;
postDur = RTseg(1).CndTiming.postludeDurSec;

% raw files
for c = 1:length(condNames)
    for t = 1:length(trials)
        filePaths_raw(c,t) = {sprintf('%s/Raw_%s_t%03d.mat', dataFolder, condNames{c}, t)};
        if exist(filePaths_raw{c,t},'file') == 2; 
            allData(c,t) = load(filePaths_raw{c,t});
            cycleStart = preDur*allData(c,t).FreqHz; % trial num after prelude  
            cycleEnd = postDur*allData(c,t).FreqHz; % trial num before postlude
            rawData(:,t,c) = allData(c,t).RawTrial(cycleStart+1:(end-cycleEnd), 2); % int at end controls column you want to look at
%             normRD(:,t,c) = rawData(:,t,c) - mean(rawData(:,t,c),1);
%             z(:,t,c) = normRD(:,t,c)./std2(rawData(:,t,c)); 
        else 
            rawData(:,t,c) = nan(size(rawData(:,t-1,c)));
        end
    end
end

plotData = false;
for c=1:length(condNames)
    concatData(:,c) = reshape(rawData(:,:,c),size(rawData,1)*size(rawData,2),1);
%     concatNorm(:,c) = reshape(normRD(:,:,c),size(rawData,1)*size(rawData,2),1);
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

% plot pairSep vs proportion of AM, AMB, and FLA in 3 sep curves

pairSep = [10,12,14,14.5,15,15.5,16,18,20];
states = {'AM','AMB','FLA'};
for i = 1:3
%     subplot(3,1,i) % plot separately
    plot(pairSep,concatState(:,i))
    hold on % plot together
%     title(sprintf('Subplot %d: %s', i, states{i})) % plot separately
    title('Pair Separation vs Percept, 2 Hz')
    legend('AM','AMB','FLA') % plot together
    xlabel('Pair Sep (lam)')
    ylabel('Proportion (%)')
end

%squeeze(nanmean(rawData,2)); % averaging across all 5 trials in ONE CHANNEL, ONE CONDITION

sampRate = allData(1,1).FreqHz;
% cutIdx = 30; % where you want to cut it
% [pCut, realFreqCut] = temp2spec(sampRate,grandAve,length(cond),cutIdx);

% freqROI = 10;
% SNR = SNRcalc(pCut,realFreqCut, freqROI)

% 
% isTimeCut = false;
% if isTimeCut == true
%     xTime1 = 0; % start time
%     xTime2 = 30; % end time; max = 36
%     [timeCut, grandAveCut] = modTime(cond, Fs, xTime1, xTime2, grandAve);
% else
%     timeCut = linspace(0,30,size(rawData(:,1,1),1));
%     grandAveCut = trialAve;
% end
% 
% if btnOnly == false
%     for c = 1:length(condNames)
%         subplot(length(condNames),2, 1 + 2*(c-1))
%         plot(realFreqCut,pCut(:,c));
%         title(sprintf('Subplot %d: Spectral, Cond. %d', c, condNames{c}))
%         xlabel('Frequency (Hz)')
%         ylabel('Power')
%         if strcmp(dataSet,'fake');
%             axis([0 50 0 1.5]);
%         end
%     end
% 
%     for c = 1:length(condNames)
%         subplot(length(condNames),2,2 + 2*(c-1))
%         plot(timeCut, grandAveCut(:,c));
%         title(sprintf('Subplot %d: Temporal, Cond. %d', c + length(condNames), condNames{c}))
%         xlabel('Time (s)')
%         ylabel('Potential (V)')
%     end
%     
% else
%     for c = 1:length(condNames)
%         subplot(length(condNames),1,c)
%         plot(timeCut, grandAveCut(:,c));
%         title(sprintf('Subplot %d: Temporal, Cond. %d', c, c))
%         xlabel('Time (s)')
%         ylabel('Potential (V)')
%     end
% end
% 

% 
