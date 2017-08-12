% (1) take raw data, eliminate pre-lude and post-lude from data (first and last
% 3 secs)
% (2) for each of the 9 conditions, identify % time spent in each of the
% three states (-4000,0,4000)
% (3) concatenate raw data (without pre- and post), and make an image,
% across conditions (imagesc)

% clear all;
close all;
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
addpath(genpath(codeFolder));

btnOnly = true;
dataSet = '6jun16_Test'; % name of folder containing .mat files
dataFolder = sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%s', dataSet);
condNames = {'c001','c002','c003','c004','c005','c006','c007','c008','c009'};
% condNames = {'c001','c008','c009'};
trials = [1:5]; 
seg = 3;
numChans = length(trials);
sampRate = 432;
filePaths_raw = cell(length(condNames),length(trials)); 

filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder, seg);
RTseg = load(filePath_seg);
preDur = RTseg(1).CndTiming.preludeDurSec;
postDur = RTseg(1).CndTiming.postludeDurSec;

% raw files
for c = 1:length(condNames)
    for t = 1:length(trials)
        % filePaths(c,t) = {sprintf('/Volumes/Denali_4D2/BethanyHung/EEG_tutorial/Raw_%s_%s.mat', condNames{c}, chans{t})}; 
        filePaths_raw(c,t) = {sprintf('%s/Raw_%s_t%03d.mat', dataFolder, condNames{c}, t)};
        if exist(filePaths_raw{c,t}) == 2; 
            allData(c,t) = load(filePaths_raw{c,t});
            cycleStart = preDur*allData(c,t).FreqHz; % trial num after prelude  
            cycleEnd = postDur*allData(c,t).FreqHz; % trial num before postlude
            rawData(:,t,c) = allData(c,t).RawTrial(cycleStart+1:(end-cycleEnd), 2); % int at end controls column you want to look at
            normRD(:,t,c) = rawData(:,t,c) - mean(rawData(:, t,c));
            z(:,t,c) = normRD(:,t,c)./std2(rawData(:,t,c)); 
        else 
            rawData(:,t,c) = nan(size(rawData(:,t-1,c)));
        end
    end
end

% Axx files
% for i = 1:length(cond)
%         filePathsAxx(i) = {sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%d%s16_data_%s/Axx_c00%d.mat',day,month,subjName,i)};
%         if exist(filePaths{i}) == 2;
%             axxData(i) = load(filePaths{i,j});
%             rawTrials(:,:,i,j) = allData(i,j).RawTrial(:,1);
% %             rawTrials(:,:,i,j) = allData(i,j).RawTrial(:,1:2); if you
% %             want to take columns 1 AND 2
%             grandAve(:,i) = squeeze(squeeze(nanmean(rawTrials(:,:,i,avgIdx),4)));
%         else
% 
%         end


for c=1:length(condNames)
    concatData(:,c) = reshape(rawData(:,:,c),size(rawData,1)*size(rawData,2),1);
    concatNorm(:,c) = reshape(normRD(:,:,c),size(rawData,1)*size(rawData,2),1);
    %subplot(length(condNames),1,c);
    figure;     
    title(sprintf('cond%d',c));
    plot(concatData(:,c));
    hold on
    ylim([-20000,20000]);
    hold off
%     plot(concatData(:,c));
end

%squeeze(nanmean(rawData,2)); % averaging across all 5 trials in ONE CHANNEL, ONE CONDITION

Fs = 432; % sampling rate
% cutIdx = 30; % where you want to cut it
% [pCut, realFreqCut] = temp2spec(Fs,grandAve,length(cond),cutIdx);

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
% % function that will read data across cycles and detect changes and output
% % a new data set
% % if changes occur over too few cycles (n=30), grab mean of ± 20
% % surrounding cycles and fill in the gap
% 
% 
