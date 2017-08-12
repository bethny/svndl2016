%% SET UP AND DEFINE VARIABLES ? EEG ONLY
clear all
close all
parentFolder = '/Users/bethanyhung/Desktop/Everything/Summer_2016/Coherent Motion non-code'; % replace with own central directory
codeFolder = '/Users/bethanyhung/code/git/svndl2016/Coherent_Motion/Functions'; 
addpath(genpath(codeFolder));

dataSet = {'10aug16_0040_dF','12aug16_1116_dF','15aug16_0034_dF','17aug16_1114_dF','18aug16_0014_dF'}; % 
names = {'0040','1116','0034','1114','0014'}; % 
shifts = {[25.74 35.46 150],[33.39 48.11 150],[36.31 52.87 150],[28.33 37.25 150],[29.16 38.33 150]}; % 
direction = 'diagonal';
filterTime = true;
timeLimit = 2700; % time (in ms) after which responses turn into NaNs 

%% GET EEG BUTTON PRESS DATA
for s = 1:length(dataSet)
    curShifts = shifts{s};
    dataFolder = sprintf('%s/EEG/%s', parentFolder, dataSet{s});   % replace with own directory                                         
    [rawData,sorted] = dataFilter(dataFolder,direction,filterTime,timeLimit); 
    [respOnly(:,s), avgDirEEG(s,:), avgAxisEEG(s,:), percIndivEEG(:,:,s), avgPairsEEG(:,:,s), avgCorrectLabels, numNansVecEEG(s,:)] = percCorrect(rawData,curShifts,direction,'EEG');
    respTimes(:,s) = sorted(:,3);
end

%% DATA SORTING

% RLA parameters; # of milliseconds to keep pre & post response
pre = 1400;
post = 100;
sampRate = 420;

startTime = sampRate+1;
endTime = sampRate*2.5;

tic
for s = 1:length(dataSet)
    tCount = zeros(1,6);
    fprintf('Running subject %s\n',dataSet{s});
    dataFolder = sprintf('%s/EEG/%s', parentFolder,dataSet{s});
    dataFiles = mySubFiles(dataFolder,'Raw',1); % dataFiles = subfiles([dataFolder,'/Raw*'],1);    
    for t=1:length(dataFiles)
        trialInfo(t,:,s) = genTrialInfo(t,dataFolder,dataFiles,respOnly(:,s),respTimes(:,s),pre,post);        
        if logical(trialInfo(t,3,s)) && ~isnan(trialInfo(t,2,s)) % if there is data (not NaNs)
            switch trialInfo(t,1,s) % what's the condition
                case {1,4,7,10}
                    condIdx = 1;
                case {2,5,8,11}
                    condIdx = 2;
                otherwise
                    condIdx = 3;
            end
            if trialInfo(t,2,s) == 0    % if incorrect
                condIdx = condIdx+3;
            else
            end
            tCount(condIdx) = tCount(condIdx)+1;
            data_SLA{condIdx,s}(:,:,tCount(condIdx)) = extractDataCM(dataFolder, dataFiles{t});
            trialIdx{condIdx,s}(tCount(condIdx)) = t;
        else
            trialInfo(t,2:end,s) = NaN;
        end
    end    
    data_RLA(:,s) = RLAcut(data_SLA(:,s),sampRate,trialInfo(:,:,s),trialIdx(:,s));
end

data_SLA = cellfun(@(x) x(startTime:endTime,:,:), data_SLA,'uni',false);
data_RLA_avg = cellfun(@(x) nanmean(x,3), data_RLA,'uni',false);
data_SLA_avg = cellfun(@(x) nanmean(x,3), data_SLA,'uni',false);
numResp = cell2mat(cellfun(@(x) size(x,3), data_RLA,'uni',false));
toc

allDataXLA = {data_SLA_avg,data_RLA_avg}; % all data, S/RLA 
    
%% MAX DIFF

useRLA = false;
dirResData = sprintf('%s/Figures',parentFolder); % replace with own directory
timeCourseLen = 1500;
dSet1 = {data_SLA_avg(2,:), data_RLA_avg(2,:)}; % currently set to plot 50% thresh conditions
dSet2 = {data_SLA_avg(5,:), data_RLA_avg(5,:)};

% plot all correct vs all incorrect (regardless of disp)
% plot ALL of cond 1 vs ALL of cond 3 (regardless of correct/incorrect) 

maxDiff(dSet1{useRLA+1}, dSet2{useRLA+1}, {'correct','incorrect'}, dirResData, timeCourseLen, useRLA)

%% PLOTS

chanROI = [67, 61, 60, 66, 71, 62]; % from RLA maxDiff plots
% 70 74 75 81 82 83 occ ROI / [90,94,95,96,99] % from SLA maxDiff plots

for i = 1:length(allDataXLA) % i=1 for SLA, i=2 for RLA
    chanAvg = cellfun(@(x) nanmean(x(:,chanROI),2), allDataXLA{i},'uni',false);
    chanAvg_mat = reshape(cat(2,chanAvg{:}),[630,6,5]);
    grandAvg(:,:,i) = nanmean(chanAvg_mat,3);
    SEM_grand(:,:,i) = nanstd(chanAvg_mat,0,3)./sqrt(length(dataSet));
end

smaller = true;

yLims = {[-3000 3000],[-1500 1500]};
numTimept = length(grandAvg); % 630
lWidth = 1.5; fSize = 10;
gcaOptsSLA = {'XTick',linspace(0,numTimept,4),'XTickLabel',{'1000','1500','2000','2500'},'XLim',[0 numTimept],'YLim',yLims{smaller+1},'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
gcaOptsRLA = {'XTick',linspace(0,numTimept,4),'XTickLabel',{'-1400','-900','-400','+100'},'XLim',[0 numTimept],'YLim',yLims{smaller+1},'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
gcaOptsXLA = {gcaOptsSLA, gcaOptsRLA};
red25 = [255 191 191]/255;
blue25 = [191 191 255]/255;

threshNames = [75, 50, 150];
strLines = {[840 840],[588 588]};
XLA = {'SLA','RLA'};

figure
for i = 1:2 % SLA & RLA 
    for h = 1:3 % 3 displacements
        if i == 1
            subplot(3,2,2*h-1) % SLA plots
        else
            subplot(3,2,2*h) % RLA plots
        end
            hold on
            plot(strLines{i},yLims{smaller+1},'--','color','k')        
            shadedEB(grandAvg(:,h,i),SEM_grand(:,h,i),blue25)           
            shadedEB(grandAvg(:,h+3,i),SEM_grand(:,h+3,i),red25)
            pH(1,:) = plot(grandAvg(:,h,i),'color','b');
            pH(2,:) = plot(grandAvg(:,h+3,i),'color','r');         
            title(sprintf('%d thresh, occ ROI: %s',threshNames(h),XLA{i}))
            set(gca,gcaOptsXLA{i}{:})
            xlabel('ms');
            ylabel('Potential');
            legend(pH,{'correct','incorrect'},'Location','southwest')
    end
end
%% BAR PLOTS FOR CORRECT/INCORRECT BUTTON RESPONSES
lWidth=2;
gcaOpts = {'box','off','tickdir','out','fontname','Arial','linewidth',lWidth,'fontsize',12};

figure
for s = 1:length(dataSet)
    subplot(2,length(dataSet),s)
    hold on
        y1 = numResp(1:3,s);
        x1 = 1:numel(y1);
        bar(x1,y1,.8,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
        for i = 1:numel(y1)
            text(x1(i),y1(i),num2str(y1(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
        end
        title(sprintf('Resp, cor: %s',names{s}))
        axis([0.5 3.5 0 160])
        ax = gca;
        for i = 1:length(shifts{s})
            ax.XTickLabel{i} = shifts{s}(i);
        end
        ylabel('Num resp')
        set(gca,gcaOpts{:})
    subplot(2,length(dataSet),s+length(dataSet))
    hold on
        y2 = numResp(4:6,s);
        x2 = 1:numel(y1);
        bar(x2,y2,.8,'FaceColor',[229/255,66/255,66/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
        for i = 1:numel(y1)
            text(x2(i),y2(i),num2str(y2(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
        end
        title(sprintf('Resp, inc: %s',names{s}))
        axis([0.5 3.5 0 160])
        ax = gca;
        for i = 1:length(shifts{s})
            ax.XTickLabel{i} = shifts{s}(i);
        end
        ylabel('Num resp')
        set(gca,gcaOpts{:})
end

%% NUMBER OF REJECTED TRIALS PER CONDITION
figure
for s = 1:length(dataSet)
    subplot(length(dataSet),1,s)
    bar(numNansVecEEG(s,:),.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    title(sprintf('Num rejected trials/condition, subj %s',names{s}))
    axis([0.5 length(numNansVecEEG)+1.5 0 15])
    ax = gca;
    ylabel('Number of trials')
    xlabel('Condition')
    set(gca,gcaOpts{:})
end

%% HISTOGRAM OF TRIAL LENGTHS
edges = [0:0.025:5.1];
category = {'c75','c50','c150','w75','w50','w150'};

for s = 1:length(dataSet)
    figure
    for t = 1:length(trialIdx) % 6
        curTrialInfo = trialInfo(:,:,s);
        relevantTimes = curTrialInfo(trialIdx{t,s},4);
        subplot(2,3,t)
            histogram(relevantTimes,edges,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
            axis([1.5 2.5 0 60])
            xlabel('Trial length (s)')
            ylabel('Number of trials')  
            title(sprintf('Resp times, %s: %s',category{t},names{s}))     
            set(gca,gcaOpts{:})
    end
end
    
%% PSYCHOPHYSICS, FOR COMPARISON ? GENERATING VARIABLES 

psychParent = sprintf('%s/Psychophysics',parentFolder);
dS = '9aug16_BH'; % unique to BH because different displacements were used 
name = 'BH';
shiftsBH = [10 30 40 50 60 70 80 100];
clear rawData
dataFolder = sprintf('%s/%s', psychParent, dS);                             
rawData = dataFilter(dataFolder,direction,filterTime,timeLimit);
[~,avgDirPsy, avgAxisPsy, ~, avgPairsPsy, ~, ~] = percCorrect(rawData,shiftsBH,direction);

dataSetP = {'11aug16_RJ','11aug16_AN','15aug16_JM','10aug16_PK'}; % datasets for psychophysics
namesP = {'RJ','AN','JM','PK'};
shiftsP = [10 30 40 50 60 70 80 100 150]; 

for s = 1:length(dataSetP)
    clear rawData
    dataFolder = sprintf('%s/%s', psychParent, dataSetP{s}); % replace with own directory                               
    rawData = dataFilter(dataFolder,direction,filterTime,timeLimit);
    [~,avgDirPsy(s+1,:), avgAxisPsy(s+1,:), ~, avgPairsPsy(:,:,s+1), ~, ~] = percCorrect(rawData,shiftsP,direction);
end

%% PSYCHOPHYSICS PLOTS + NEW EEG RESP DATA POINTS
condColor = colorGen(length(dataSet));
xFine = linspace(0,160,200);
pInit.t = 20;
pInit.b = -2;

figure
hold on
s = 1; % BH's data 
    dataEEG.x = shifts{s};
    dataEEG.y = avgDirEEG(s,:);
    dataPsy.x = shiftsBH;
    dataPsy.y = avgDirPsy(s,1:end-1);
    pInit.g = 0.25;
    pInit.e = 0.5;
    [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},dataPsy,'Weibull');
    y1 = Weibull(pBest,xFine);
    i(1) = plot(dataEEG.x,dataEEG.y,'c*-','color',condColor{s});
    plot(xFine,y1,'-','LineWidth',2,'color',condColor{s}); % weibull curve

for s = 2:length(dataSet) % everyone else's data
    dataEEG.x = shifts{s};
    dataEEG.y = avgDirEEG(s,:);
    dataPsy.x = shiftsP;
    dataPsy.y = avgDirPsy(s,:);
    pInit.g = 0.25;
    pInit.e = 0.5;
    [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},dataPsy,'Weibull');
    y1 = Weibull(pBest,xFine);
    plot(xFine,y1,'-','LineWidth',2,'color',condColor{s});   
    i(s) = plot(dataEEG.x,dataEEG.y,'c*-','color',condColor{s});
end
title('Direction, psychophysics vs EEG')
legend(i,names)
xlabel('Shift distance (arcmin)')
ylabel('Proportion correct')
set(gca,gcaOpts{:})
    