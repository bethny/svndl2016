clear all;
% close all;
codeFolder = '/Users/bethanyhung/code/git/svndl2016/Apparent_Motion/Functions';
addpath(genpath(codeFolder));

dataSet = {'16jun16_0037'}; % names of folders containing .mat files
names = {'0037'};
PSE = 35.68; % change for person you're analyzing
frequency = '2Hz';
contrast = '50% con';

for s = 1:size(dataSet,2)
    dataFolder{s} = sprintf('/Users/bethanyhung/Desktop/EVERYTHING/Summer_2016/Apparent Motion non-code/Older_Iterations/%s', dataSet{s});
end

condNames = 1:5;
trials = 1:10; 
seg = 2; % seg you want to look at; generally irrelevant, keep at 2
filePaths_raw = cell(length(condNames),length(trials)); 
filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder{1}, seg);
RTseg = load(filePath_seg);
preDur = RTseg(1).CndTiming.preludeDurSec;
postDur = RTseg(1).CndTiming.postludeDurSec;
shift = 0.5; % # of seconds you want to delete from front
epochT = [0.5,2]; % length of an epoch; [plotting one cycle, FFT]
numChan = 5;

for c = 1:length(condNames) % only loads data for ONE participant at a time
    for t = 1:length(trials)
        filePaths_raw(t,c) = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{1}, c, t)};
        if exist(filePaths_raw{t,c},'file') == 2; 
            allData(t,c) = load(filePaths_raw{t,c});
            sampRate = allData(1,1).FreqHz;
            cycleStartBTN = ceil((preDur-0.5)*allData(1,1).FreqHz); % trial num after prelude
            cycleStartEEG = preDur*allData(1,1).FreqHz;
            cycleEnd = postDur*allData(1,1).FreqHz; % trial num before postlude
            rawData(:,t,c) = double(allData(t,c).RawTrial(:, numChan+1)); % int at end controls column you want to look at %% ONLY FOR BUTTON
            rawDataShifted(:,t,c) = rawData(ceil(sampRate*shift):end,t,c); % first 500 ms of data discarded
            rawDataBTN(:,t,c) = rawDataShifted(cycleStartBTN+1:(end-cycleEnd),t,c); % 500ms shifted & pre/postlude discarded
            rawDataEEG(:,1:numChan,t,c) = double(allData(t,c).RawTrial(cycleStartEEG+1:(end-cycleEnd), 1:numChan)); % int at end controls column you want to look at
        else
            rawData(:,t,c) = nan(size(rawData(:,1,1,1)));
            rawDataShifted(:,t,c) = nan(size(rawDataShifted(:,1,1,1)));
            rawDataBTN(:,t,c) = nan(size(rawDataBTN(:,1,1,1)));
            rawDataEEG(:,:,t,c) = nan(size(rawDataEEG(:,:,1,1,1)));
        end
    end
end

%% PLOTTING EEG TRACES, AVERAGED OVER EPOCH
close all
numTimept = floor(sampRate*epochT(1)); % 216 per epoch? ? ? 
lWidth = 1.5;
fSize = 10;
gcaOpts1 = {'XTick',linspace(0,numTimept,6),'XTickLabel',{'0','100','200','300','400','500'},'XLim',[0 numTimept],'YLim',[-600 600],'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
    
[posEEGAvg,zeroEEGAvg,negEEGAvg,singleAvg,timeConcatBTN] = classifyData(rawDataBTN,rawDataEEG,sampRate,epochT(1));

figure
for h = 1:numChan
    for n = 1:length(trials)/2
        subplot(5,1,n)
            plot(posEEGAvg{2}(:,h),'color','r')
            hold on
            plot(negEEGAvg{2}(:,h),'color','b')
            plot(singleAvg{1}(:,h)+singleAvg{2}(:,h),'color','g')
            hold off
            title(sprintf('AM, FLA bistable, Ch %d',n))
%                     labels = {'FLA','AM','Summed'};
%                     legend(labels)
            ax = gca;
            set(gca,gcaOpts1{:})
    end
end

%%
figure
for h = 1:numChan
    subplot(5,5,5*h-4)
        plot(negEEGAvg{1}(:,h),'color','b')
        title(sprintf('AM, minExtreme, Ch %d',h))
        ax = gca;
        set(gca,gcaOpts1{:})
        ylabel('Potential (V)')
        xlabel('Time (ms)')
        axis([0 216 -600 600])
    subplot(5,5,5*h-3)
        plot(posEEGAvg{2}(:,h),'color','r')
        hold on
        plot(negEEGAvg{2}(:,h),'color','b')
        hold off
        title(sprintf('AM, FLA bistable, Ch %d',h))
%             labels = {'FLA','AM'};
%             legend(labels)
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(5,5,5*h-2)
        plot(posEEGAvg{3}(:,h),'color','r')
        title(sprintf('FLA, maxExtreme, Ch %d',h))
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(5,5,5*h-1)
        plot(singleAvg{1}(:,h),'color','r')
        title(sprintf('FLA, Left Patch, Ch %d',h))
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(5,5,5*h)
        plot(singleAvg{2}(:,h),'color','r')
        title(sprintf('FLA, Right Patch, Ch %d',h))
        ax = gca;
        set(gca,gcaOpts1{:})
end

%% FAST FOURIER TRANSFORM

[epochsEEG,~] = cutEpochs(rawDataBTN,rawDataEEG,sampRate,epochT(2));
avgedEpoch = squeeze(nanmean(epochsEEG,2));
% cutIdx = 30;

power = false;
[pCut, realFreqCut] = temp2spec2(sampRate, avgedEpoch, power); 

xMax = 30;
figure
for c = 1:length(condNames)
    for h = 1:numChan
        subplot(length(condNames),numChan, c+(h-1)*5)
        plot(realFreqCut,pCut(:,c,h));
        title(sprintf('C. %d, Ch. %d', c,h))
        xlabel('Frequency (Hz)')
        if power == true
            ylabel('Power')
        else
            ylabel('Amplitude')
        end
        axis([0 xMax 0 200])
    end
end

%% HARMONICS

close all
evenHarmIdx = 4:4:realFreqCut(end);
oddHarmIdx = 2:4:realFreqCut(end);
evenHarm = pCut(evenHarmIdx,:,:);
oddHarm = pCut(oddHarmIdx,:,:);

figure
for c = 1:length(condNames)
    for h = 1:numChan   
        subplot(length(condNames),numChan, c+(h-1)*5)
        plot(evenHarmIdx,evenHarm(:,c,h),'color','r')
        hold on
        plot(oddHarmIdx,oddHarm(:,c,h),'color','b')
        labels2 = {'Even','Odd'};
        legend(labels2)
        title(sprintf('C. %d, Ch. %d', c,h))
        axis([0 30 0 200])
        hold off
    end
end

figure
for c = 1:length(condNames)
    for h = 1:numChan   
        subplot(length(condNames),numChan, c+(h-1)*5)
        bar(evenHarm(1:3,c,h))
        title(sprintf('Even C. %d, Ch. %d', c,h))
        ax=gca;
        ax.XTickLabel = {'4','8','12'};
        ylabel('Potential (V)')
        xlabel('Harmonic')
    end
end

figure
for c = 1:length(condNames)
    for h = 1:numChan 
        subplot(length(condNames),numChan, c+(h-1)*5)
        bar(oddHarm(1:3,c,h))
        title(sprintf('Odd C. %d, Ch. %d', c,h))
        ax=gca;
        ax.XTickLabel = {'2','6','10'};
        ylabel('Potential (V)')
        xlabel('Harmonic')
    end
end

%% PSYCHOPHYSICS // CURVE FITTING
% write some code that determines the percentage of time spent in AM or FLA
% for ambiguous condition
[AM] = stateIdx(timeConcatBTN);

gcaOpts = {'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
condColor = {[229/255,66/255,66/255],[35/255,169/255,181/255],[249/255,216/255,127/255],[186/255,122/255,246/255]};
pairSep = [16,PSE,50];
fit = 'logit'; % 'logit' or 'probit'

figure
    [coeffsAM, statsAM, curveAM, thresholdAM] = FitPsycheCurveLogit(pairSep, AM(1:3), fit); 
    hold on
    plot(curveAM(:,1),curveAM(:,2),'--','linewidth',lWidth,'color',condColor{2})
    plot(pairSep,AM(1:3),'o','color',condColor{2});
    title(sprintf('Apparent Motion: %s at %s, %s fit', frequency, contrast, fit))
    ylabel('Proportion (%)')
    xlabel('Pair separation (lambda)')
    for i = 1:length(names)
        labels(2*i) = {names{i}};
        labels(2*i-1) = {sprintf('%s fit',names{i})};
    end
    legend(labels)
    set(gca,gcaOpts{:})
    hold off

figure
    y = [thresholdAM, mean(thresholdAM)];
    x = [1:numel(y)];
    bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    for i = 1:numel(y)
        text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
    title(sprintf('PSE, %s at %s', frequency, contrast))
    axis([0.5 length(dataSet)+1.5 0 45])
    ax = gca;
    for i = 1:length(names)
        ax.XTickLabel(i) = {names{i}};
        ax.XTickLabel(length(names)+1) = {'Mean'};
    end
    ylabel('Pair Separation (lambda)')
    set(gca,gcaOpts{:})

%% RASTER PLOT

[RGBMat] = rasterizeData(condNames,rawDataBTN,trials);
gray = zeros(1,size(RGBMat,2),1)+240/255;

for d = 1:3
    RGBMatDiv(:,:,d) = [RGBMat(1:10,:,d); gray; RGBMat(11:20,:,d); gray; RGBMat(21:30,:,d); gray; RGBMat(31:40,:,d); gray; RGBMat(41:50,:,d)];
end

figure
imagesc(RGBMatDiv(:,:,:))
    title(sprintf('%s, %s, %s',names{s},frequency,contrast))
    ax = gca;
    ax.YTick = 11*[0:4]+5;
    ax.YTickLabel = {'1','2','3','4','5'};
    ax.XTick = linspace(0,size(RGBMat,2),7);
    ax.XTickLabel = {'30','5','10','15','20','25'};
    ylabel('Condition')
    xlabel('Time (sec)')
    set(gca,gcaOpts{:})