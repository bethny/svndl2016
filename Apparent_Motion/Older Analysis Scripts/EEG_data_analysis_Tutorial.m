clear all;
close all;
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
addpath(genpath(codeFolder));

dataSet = 'Tutorial'; % name of folder containing .mat files
dataFolder = sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%s', dataSet);
condNames = {'c002','c003', 'c006', 'c007'};
trials = [1:5]; 
seg = 1;
numChans = length(trials);
sampRate = 432;
filePaths_raw = cell(length(condNames),length(trials)); 

if ~strcmp(dataSet,'fake');

    filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder, seg);
    RTseg = load(filePath_seg);
    preDur = RTseg(1).CndTiming.preludeDurSec;
    postDur = RTseg(1).CndTiming.postludeDurSec;
    cycleStart = preDur*sampRate; % trial num after prelude  
    cycleEnd = postDur*sampRate; % trial num before postlude
    for c = 1:length(condNames)
        for t = 1:length(trials)
    %       filePaths(c,t) = {sprintf('/Volumes/Denali_4D2/BethanyHung/EEG_tutorial/Raw_%s_%s.mat', condNames{c}, chans{t})}; 
            filePaths_raw(c,t) = {sprintf('%s/Raw_%s_t%03d.mat', dataFolder, condNames{c}, t)};
            if exist(filePaths_raw{c,t}) == 2; 
               allData(c,t) = load(filePaths_raw{c,t});
               rawtrial = allData(1,1).RawTrial;
               rawData(:,:,t,c) = allData(c,t).RawTrial(cycleStart+1:(end-cycleEnd), 1:5);
            else 
               rawData(:,:,t,c) = nan(size(rawData(:,:,t-1,c)));
            end
        end
    end

    
    trialAve = squeeze(nanmean(rawData,3)); % averaging across all 5 trials in ONE CHANNEL, ONE CONDITION
    avgIdx = 1; % channels you want to average over OR pick channel you want to see
    grandAve = squeeze(nanmean(trialAve(:,avgIdx,:),2)); % all conditions SEPARATE

    Fs = 432;
    cutIdx = 10; % where you want to cut it
    [pCut, realFreqCut] = temp2spec(Fs,grandAve,length(condNames),cutIdx);
    freqROI = 9.36;
    SNR = SNRcalc(pCut,realFreqCut, freqROI)
    condLabels = {2,3,6,7};
    xTime1 = 0; % start time
    xTime2 = 1; % end time
%     [grandAveCut] = modT%me(Fs, xTime1, xTime2, grandAve);
    timeCut = linspace(xTime1,xTime2,Fs*(xTime2-xTime1));
    for c = 1:length(condNames)
        grandAveCut(:,c) = grandAve(Fs*xTime1+1:Fs*xTime2,c);
    end

else 
    N = 4800; %cycleEnd - cycleStart + 1;
    sampRate = 432;
    amp = 1;
    freqROI = [9.43 10 10.82 15]; 
    timeEnd = 1; % 0 to timeEnd = x axis for temporal graphs
    [realFreqCut,pCut,grandAveCut,timeCut] = genSine(N, sampRate, amp, freqROI, timeEnd);
    condLabels = {freqROI(1), freqROI(2), freqROI(3), freqROI(4)}; 
    % realFreqCut is actually just fake freq
    % pCut is actually just fake P
    % grandAveCut: raw sine wave data, cut (fCut)
end
    

for c = 1:length(condNames)
    subplot(length(condNames),2, 1 + 2*(c-1))
    plot(realFreqCut,pCut(:,c));
    title(sprintf('Subplot %d: Spectral, Cond. %d', c, condLabels{c}))
    xlabel('Frequency (Hz)')
    ylabel('Power')
    if strcmp(dataSet,'fake');
        axis([0 50 0 1.5]);
    end
end

for c = 1:length(condNames)
    subplot(length(condNames),2,2 + 2*(c-1))
    plot(timeCut, grandAveCut(:,c));
    title(sprintf('Subplot %d: Temporal, Cond. %d', c + length(condNames), condLabels{c}))
    xlabel('Time (s)')
    ylabel('Potential (V)')
end