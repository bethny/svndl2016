clear all;
close all;
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
addpath(genpath(codeFolder));

dataSet = {'16jun16_0037'}; % names of folders containing .mat files
names = {'0037'};
PSE = [34.36,35.68]; % change for person you're analyzing
frequency = '2Hz';
contrast = '50% con';
channelROI = 1; % when multiple people are being processed
colors = {'r','b','g'};

for s = 1:length(dataSet)
    dataFolder{s} = sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%s', dataSet{s});
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
        for s = 1:length(dataSet)
            filePaths_raw(t,c,s) = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{s}, c, t)};
            if exist(filePaths_raw{t,c,s},'file') == 2; 
                allData(t,c,s) = load(filePaths_raw{t,c,s});
                sampRate = allData(1,1,1).FreqHz;
                cycleStartBTN = ceil((preDur-0.5)*allData(1,1,1).FreqHz); % trial num after prelude
                cycleStartEEG = preDur*allData(1,1,1).FreqHz;
                cycleEnd = postDur*allData(1,1,1).FreqHz; % trial num before postlude
                rawData(:,t,c,s) = double(allData(t,c,s).RawTrial(:, numChan+1)); % int at end controls column you want to look at %% ONLY FOR BUTTON
                rawDataShifted(:,t,c,s) = rawData(ceil(sampRate*shift):end,t,c,s); % first 500 ms of data discarded
                rawDataBTN(:,t,c,s) = rawDataShifted(cycleStartBTN+1:(end-cycleEnd),t,c,s); % 500ms shifted & pre/postlude discarded
                rawDataEEG(:,1:numChan,t,c,s) = double(allData(t,c,s).RawTrial(cycleStartEEG+1:(end-cycleEnd), 1:numChan)); % int at end controls column you want to look at
            else
                rawData(:,t,c,s) = nan(size(rawData(:,1,1,1)));
                rawDataShifted(:,t,c,s) = nan(size(rawDataShifted(:,1,1,1)));
                rawDataBTN(:,t,c,s) = nan(size(rawDataBTN(:,1,1,1)));
                rawDataEEG(:,:,t,c,s) = nan(size(rawDataEEG(:,:,1,1,1)));
            end
        end
    end
end

%% PLOTTING EEG TRACES, AVERAGED OVER EPOCH
close all
numTimept = floor(sampRate*epochT(1)); % 216 per epoch? ? ? 
lWidth = 1.5;
fSize = 10;
gcaOpts1 = {'XTick',linspace(0,numTimept,6),'XTickLabel',{'0','100','200','300','400','500'},'XLim',[0 numTimept],'YLim',[-600 600],'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
    
[posEEGAvg,zeroEEGAvg,negEEGAvg,singleAvg,timeConcatBTN] = classifyDataMult(rawDataBTN,rawDataEEG,sampRate,epochT(1));

figure
for h = 1:numChan % testing for linear additivity
    for s = 1:length(dataSet)
        subplot(numChan,length(dataSet),(-1+2*h)+(s-1))
            plot(posEEGAvg{2,s}(:,h),'color','r')
            hold on
            plot(negEEGAvg{2,s}(:,h),'color','b')
            plot(singleAvg{1}(:,h,s)+singleAvg{2}(:,h,s),'color','g')
            hold off
            title(sprintf('AM, FLA bistable, Ch %d, Sub %s',h,names{s}))
%                     labels = {'FLA','AM','Summed'};
%                     legend(labels)
            ax = gca;
            set(gca,gcaOpts1{:})
    end
end

if length(dataSet) == 1
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
    
else
    figure % looking at one spec channel
    for c = 1:length(condNames)
        for s = 1:length(dataSet)
            subplot(numCond,length(dataSet)+1,1+(s-1))
                plot(negEEGAvg{1,s}(:,channelROI),'color',colors{s})
                title(sprintf('AM, minExtreme, Subj %s',names{s}))
                ax = gca;
                set(gca,gcaOpts1{:})
                ylabel('Potential (V)')
                xlabel('Time (ms)')
                axis([0 216 -600 600])
            subplot(numCond,length(dataSet)+1,4+(s-1))
                plot(posEEGAvg{2,s}(:,channelROI),'color','r')
                hold on
                plot(negEEGAvg{2,s}(:,channelROI),'color','b')
                hold off
                title(sprintf('AM, FLA bistable, Subj %s',names{s}))
        %             labels = {'FLA','AM'};
        %             legend(labels)
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,7+(s-1))
                plot(posEEGAvg{3,s}(:,channelROI),'color',colors{s})
                title(sprintf('FLA, maxExtreme, Subj %s',names{s}))
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,10+(s-1))
                plot(singleAvg{1}(:,channelROI,s),'color',colors{s})
                title(sprintf('FLA, Left Patch, Subj %s',names{s}))
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,13+(s-1))
                plot(singleAvg{2}(:,channelROI,s),'color',colors{s})
                title(sprintf('FLA, Right Patch, Subj %s',names{s}))
                ax = gca;
                set(gca,gcaOpts1{:})
                
            subplot(numCond,length(dataSet)+1,(length(dataSet)+1)*1)
                plot(negEEGAvg{1,s}(:,channelROI),'color',colors{s})
                hold on
                title('AM, minExtreme')
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,(length(dataSet)+1)*2)
                plot(posEEGAvg{2,s}(:,channelROI),'color',colors{s})
                hold on
                plot(negEEGAvg{2,s}(:,channelROI),'color',colors{s})
                title('AM, FLA bistable')
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,(length(dataSet)+1)*3)
                plot(posEEGAvg{3,s}(:,channelROI),'color',colors{s})
                hold on
                title('FLA, maxExtreme')
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,(length(dataSet)+1)*4)
                plot(singleAvg{1}(:,channelROI,s),'color',colors{s})
                hold on
                title('FLA, Left Patch')
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(numCond,length(dataSet)+1,(length(dataSet)+1)*5)
                plot(singleAvg{2}(:,channelROI,s),'color',colors{s})
                hold on
                title('FLA, Right Patch')
                ax = gca;
                set(gca,gcaOpts1{:})
        end
    end
    
    figure % multiple people overlaid on same plot
    for h = 1:numChan
        for s = 1:length(dataSet)
            subplot(5,5,5*h-4)
                plot(negEEGAvg{1,s}(:,h),'color',colors{s})
                hold on
                title(sprintf('AM, minExtreme, Ch %d',h))
                ax = gca;
                set(gca,gcaOpts1{:})
                ylabel('Potential (V)')
                xlabel('Time (ms)')
                axis([0 216 -600 600])
            subplot(5,5,5*h-3)
                plot(posEEGAvg{2,s}(:,h),'color','r')
                hold on
                plot(negEEGAvg{2,s}(:,h),'color','b')
                title(sprintf('AM, FLA bistable, Ch %d',h))
        %             labels = {'FLA','AM'};
        %             legend(labels)
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(5,5,5*h-2)
                plot(posEEGAvg{3,s}(:,h),'color',colors{s})
                hold on
                title(sprintf('FLA, maxExtreme, Ch %d',h))
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(5,5,5*h-1)
                plot(singleAvg{1}(:,h,s),'color',colors{s})
                hold on
                title(sprintf('FLA, Left Patch, Ch %d',h))
                ax = gca;
                set(gca,gcaOpts1{:})
            subplot(5,5,5*h)
                plot(singleAvg{2}(:,h,s),'color',colors{s})
                hold on
                title(sprintf('FLA, Right Patch, Ch %d',h))
                ax = gca;
                set(gca,gcaOpts1{:})
        end
    end
    
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
            for s = 1:length(dataSet)
                subplot(length(condNames),numChan, c+(h-1)*5)
                plot(realFreqCut,pCut(:,c,h,s),'color',colors{s});
                hold on
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
    end

%% HARMONICS

close all
evenHarmIdx = 4:4:realFreqCut(end);
oddHarmIdx = 2:4:realFreqCut(end);
evenHarm = pCut(evenHarmIdx,:,:,:);
oddHarm = pCut(oddHarmIdx,:,:,:);

multSubj = false;
if multSubj == false;
    subj = 1;
else
    subj = s;
end

figure
for c = 1:length(condNames)
    for h = 1:numChan   
        for s = 1:length(dataSet)
            subplot(length(condNames),numChan, c+(h-1)*5)
            plot(evenHarmIdx,evenHarm(:,c,h,subj),'color','r')
            hold on
            plot(oddHarmIdx,oddHarm(:,c,h,subj),'color','b')
            labels2 = {'Even','Odd'};
            legend(labels2)
            title(sprintf('C. %d, Ch. %d', c,h))
            axis([0 30 0 200])
        end
    end
end

figure
for c = 1:length(condNames)
    for h = 1:numChan   
        subplot(length(condNames),numChan, c+(h-1)*5)
        bar(evenHarm(1:3,c,h,subj))
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
        bar(oddHarm(1:3,c,h,subj))
        title(sprintf('Odd C. %d, Ch. %d', c,h))
        ax=gca;
        ax.XTickLabel = {'2','6','10'};
        ylabel('Potential (V)')
        xlabel('Harmonic')
    end
end

%% PSYCHOPHYSICS // CURVE FITTING

% [AM] = stateIdx(timeConcatBTN);
% 
gcaOpts = {'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
condColor = {[229/255,66/255,66/255],[35/255,169/255,181/255],[249/255,216/255,127/255],[186/255,122/255,246/255]};
% pairSep = [16,PSE,50];
% fit = 'logit'; % 'logit' or 'probit'
% 
% figure
%     [coeffsAM, statsAM, curveAM, thresholdAM] = FitPsycheCurveLogit(pairSep, AM(1:3), fit); 
%     hold on
%     plot(curveAM(:,1),curveAM(:,2),'--','linewidth',lWidth,'color',condColor{2})
%     plot(pairSep,AM(1:3),'o','color',condColor{2});
%     title(sprintf('Apparent Motion: %s at %s, %s fit', frequency, contrast, fit))
%     ylabel('Proportion (%)')
%     xlabel('Pair separation (lambda)')
%     for i = 1:length(names)
%         labels(2*i) = {names{i}};
%         labels(2*i-1) = {sprintf('%s fit',names{i})};
%     end
%     legend(labels)
%     set(gca,gcaOpts{:})
%     hold off
% 
% figure
%     y = [thresholdAM, mean(thresholdAM)];
%     x = [1:numel(y)];
%     bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
%     for i = 1:numel(y)
%         text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
%     end
%     title(sprintf('PSE, %s at %s', frequency, contrast))
%     axis([0.5 length(dataSet)+1.5 0 45])
%     ax = gca;
%     for i = 1:length(names)
%         ax.XTickLabel(i) = {names{i}};
%         ax.XTickLabel(length(names)+1) = {'Mean'};
%     end
%     ylabel('Pair Separation (lambda)')
%     set(gca,gcaOpts{:})

%% RASTER PLOT

for i = 1:length(dataSet)
    for c = 1:length(condNames)
        indivCond(c,i) = {squeeze(rawDataBTN(:,:,c,i))'};
    end
    indivMat(i) = {[indivCond{1,i};indivCond{2,i};indivCond{3,i};indivCond{4,i};indivCond{5,i}]};
end

% numTimepts = size(allData(1,1,1).RawTrial(cycleStartBTN+1:(end-cycleEnd), 2),1);
numTimepts = size(rawDataBTN,1);

for s = 1:length(dataSet)
    for i = 1:length(condNames)*length(trials)
        for j = 1:numTimepts
            if indivMat{s}(i,j) < -0.3e4 % negatives, red
                RGBMat(i,j,1,s) = 236/255;
                RGBMat(i,j,2,s) = 74/255;
                RGBMat(i,j,3,s) = 74/255;
            elseif indivMat{s}(i,j) > -0.3e4 && indivMat{s}(i,j) < 0.3e4 % zeros, orange
                RGBMat(i,j,1,s) = 249/255;
                RGBMat(i,j,2,s) = 216/255;
                RGBMat(i,j,3,s) = 127/255;
            else
                RGBMat(i,j,1,s) = 123/255;
                RGBMat(i,j,2,s) = 212/255;
                RGBMat(i,j,3,s) = 220/255; % positives, blue
            end
        end
    end
end

gray = zeros(1,numTimepts,1)+240/255;

for d = 1:3 % assuming we'll only have 5 trials per condition
    for s = 1:length(dataSet)
        RGBMatDiv(:,:,d,s) = [RGBMat(1:10,:,d,s); gray; RGBMat(11:20,:,d,s); gray; RGBMat(21:30,:,d,s); gray; RGBMat(31:40,:,d,s); gray; RGBMat(41:50,:,d,s)];
    end
end

figure
for s = 1:length(dataSet)
    subplot(1,length(dataSet),s)
    imagesc(RGBMatDiv(:,:,:,s))
    title(sprintf('%s, %s, %s',names{s},frequency,contrast))
    ax = gca;
    ax.YTick = 11*[0:4]+5;
    ax.YTickLabel = {'1','2','3','4','5'};
    ax.XTick = linspace(0,size(RGBMat,2),7);
    ax.XTickLabel = {'30','5','10','15','20','25'};
    ylabel('Condition')
    xlabel('Time (sec)')
    set(gca,gcaOpts{:})
end