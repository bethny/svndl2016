clear all;
close all;
codeFolder = '/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/Functions';
addpath(genpath(codeFolder));

% dataSet = {'13jun16_Bethany','13jun16_Peter','14jun16_Wesley','14jun16_Guillaume','20jun16_Alexandra'}; % names of folders containing .mat files
dataSet = {'22jun16_Bethany','22jun16_Peter','24jun16_Tony'};
% names = {'BH','PK','WM','GR','AY'};
names = {'BH','PK','AN'};
frequency = '2Hz';
contrast = '60% con';

for s = 1:size(dataSet,2)
    dataFolder{s} = sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/%s', dataSet{s});
end

condNames = 1:9;
trials = 1:5;
seg = 2; % seg you want to look at; generally irrelevant, keep at 2
filePaths_raw = cell(length(condNames),length(trials)); 
filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder{1}, seg);
RTseg = load(filePath_seg);
preDur = RTseg(1).CndTiming.preludeDurSec;
postDur = RTseg(1).CndTiming.postludeDurSec;

for c = 1:length(condNames)
    for t = 1:length(trials)
        for s = 1:size(dataSet,2)
            filePaths_raw(t,s,c) = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{s}, c, t)};
            if exist(filePaths_raw{t,s,c},'file') == 2; 
                allData(t,s,c) = load(filePaths_raw{t,s,c});
                cycleStart = preDur*allData(1,1,1).FreqHz; % trial num after prelude  
                cycleEnd = postDur*allData(1,1,1).FreqHz; % trial num before postlude
                rawData(:,t,s,c) = double(allData(t,s,c).RawTrial(cycleStart+1:(end-cycleEnd), 2)); % int at end controls column you want to look at
            else
                rawData(:,t,s,c) = nan(size(rawData(:,1,1,1)));
            end
        end
    end
end

%% GENERATING THE TABLE

[AM] = percentStateMult(rawData);
lWidth = 2;
fSize = 12;
gcaOpts = {'box','off','tickdir','out','fontname','Arial','linewidth',lWidth,'fontsize',fSize};
condColor = {[229/255,66/255,66/255],[35/255,169/255,181/255],[255/255,216/255,80/255],[186/255,122/255,246/255],[0 0 0]};
pairSep = [12:20]; % [16,24,28,31,33,35,38,42,50];
fit = 'logit'; % 'logit' or 'probit'

figure
    for i = 1:length(dataSet)
        [coeffsAM(:,i), statsAM(i), curveAM(:,:,i), thresholdAM(i)] = FitPsycheCurveLogit(pairSep, AM(:,i), fit); 
        hold on
        plot(curveAM(:,1,i),curveAM(:,2,i),'--','linewidth',lWidth,'color',condColor{i})
        plot(pairSep,AM(:,i),'o','color',condColor{i});
    end
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

for i = 1:length(dataSet)
    for c = 1:length(condNames)
        indivCond(c,i) = {squeeze(rawData(:,:,i,c))'};
    end
    indivMat(i) = {[indivCond{1,i};indivCond{2,i};indivCond{3,i};indivCond{4,i};indivCond{5,i};indivCond{6,i};indivCond{7,i};indivCond{8,i};indivCond{9,i}]};
end

numTimepts = size(allData(1,1,1).RawTrial(cycleStart+1:(end-cycleEnd), 2),1);

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
        RGBMatDiv(:,:,d,s) = [RGBMat(1:5,:,d,s); gray; RGBMat(6:10,:,d,s); gray; RGBMat(11:15,:,d,s); gray; RGBMat(16:20,:,d,s); gray; ...
        RGBMat(21:25,:,d,s); gray; RGBMat(26:30,:,d,s); gray;  RGBMat(31:35,:,d,s); gray; RGBMat(36:40,:,d,s); gray; RGBMat(41:45,:,d,s)];
    end
end

figure
for s = 1:length(dataSet)
    subplot(1,length(dataSet),s)
    imagesc(RGBMatDiv(:,:,:,s))
    title(sprintf('Subplot %d: %s, %s, %s',s,names{s},frequency,contrast))
    ax = gca;
    ax.YTick = 6*[0:8]+3;
    ax.YTickLabel = {'1','2','3','4','5','6','7','8','9'};
    ax.XTick = linspace(0,numTimepts,7);
    ax.XTickLabel = {'30','5','10','15','20','25'};
    ylabel('Condition')
    xlabel('Time (sec)')
    set(gca,gcaOpts{:})
end