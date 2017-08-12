clear all;
close all;
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
addpath(genpath(codeFolder));

fakeData = false; % true or false
condLabels = {2,3,7};
trials = 1:5;
RTseg = load('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Tutorial/RTSeg_s001.mat');
preDur = RTseg.CndTiming.preludeDurSec;

if ~fakeData
    for c = 1:length(condLabels)
        for t = 1:length(trials)
            filePaths(c,t) = {sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Tutorial/Raw_c%03d_t%03d.mat', condLabels{c}, t)};
            if exist(filePaths{c,t}) == 2; 
                allData(c,t) = load(filePaths{c,t});
                cycleStart = allData(1,1).FreqHz*preDur + 1;
                cycleEnd = size(allData(1,1).RawTrial,1) - allData(1,1).FreqHz*preDur;
                rawData(:,:,t,c) = double(allData(c,t).RawTrial(cycleStart:cycleEnd, 1:5));
            else 
                rawData(:,:,t,c) = nan(cycleEnd-cycleStart+1,5);
            end
        end
    end
    
rearranged = permute(rawData,[1,3,2,4]);
timeConcat = reshape(rearranged,size(rearranged,1)*size(rearranged,2),size(rearranged,3),size(rearranged,4));
Fs = allData(1,1).FreqHz;

pwr = false;
cutIdx = 30; % where you want to cut it
[pCut, realFreqCut] = temp2spec(Fs, timeConcat, pwr, cutIdx);

freqROI = 9.99;
SNR = SNRcalc(pCut,realFreqCut,freqROI)

xTime1 = 0; % start time
xTime2 = 1; % end time
[timeCut, timeConcatCut] = modTime(Fs, xTime1, xTime2, timeConcat);

else % for fake sine wave "data" 
    N = cycleEnd - cycleStart + 1;
    amp = 1;
    freqROI = [9.43 10 10.82]; 
    timeEnd = 1; % 0 to timeEnd = x axis for temporal graphs
    [realFreqCut,pCut,grandAveCut,timeCut] = genSine(N, Fs, amp, freqROI, timeEnd);
    condLabels = {freqROI(1), freqROI(2), freqROI(3)}; 
    % realFreqCut is actually just fake freq
    % pCut is actually just fake P
    % grandAveCut: raw sine wave data, cut (fCut)
end
    
chanIdx = 1; % channel you want to look at

for c = 1:length(condLabels)
    subplot(length(condLabels),2, 1 + 2*(c-1))
    plot(realFreqCut,pCut(:,chanIdx,c));
    title(sprintf('Subplot %d: Spectral, Cond. %d', c, condLabels{c}))
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    if fakeData
        axis([0 50 10e-40 10e1])
    else
        axis([0 30 0 1500])
    end
end

for c = 1:length(condLabels)
    subplot(length(condLabels),2,2 + 2*(c-1))
    plot(timeCut, timeConcatCut(:,chanIdx,c));
    title(sprintf('Subplot %d: Temporal, Cond. %d', c + length(condLabels), condLabels{c}))
    xlabel('Time (s)')
    ylabel('Potential (V)')
end

figure
for h = 1:allData(1,1).NmbChanEEG
    subplot(allData(1,1).NmbChanEEG,1,h)
    plot(realFreqCut,pCut(:,h,3));
    title(sprintf('Spectral, Cond. 7, Chan. %d', h))
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    axis([0 30 0 1500])
end