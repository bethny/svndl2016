%% SET UP AND DEFINE VARIABLES
clear all
close all
codeFolder = '/Users/bethanyhung/code/git/svndl2016/Coherent_Motion/Functions';
addpath(genpath(codeFolder));

dataSet = {'10aug16_PK','11aug16_AN','11aug16_RJ','11aug16_AL','15aug16_JM','17aug16_FK','17aug16_AY'};
names = {'PK','AN','RJ','AL','JM','FK','AY'}; %'BH','PK',
direction = 'diagonal'; % diagonal or cardinal

shifts = [10 30 40 50 60 70 80 100 150];

filterTime = true;
timeLimit = 2500;

%% GET PSYCHOPHYSICS BUTTON PRESS DATA
tic
for s = 1:length(dataSet)
    fprintf('Now running subject %s\n',names{s})
    clear rawData
    dataFolder = sprintf('/Users/bethanyhung/Desktop/EVERYTHING/Summer_2016/Coherent Motion non-code/Psychophysics/%s', dataSet{s});                                    
    rawData = dataFilter(dataFolder,direction,filterTime,timeLimit);
    allData{:,:,s} = rawData;
    [~, avgCorrectDir(s,:), avgCorrectAxis(s,:),  percIndiv(:,:,s), avgCorrectPairs(:,:,s), avgCorrectLabels, numNansVec(s,:)] = percCorrect(rawData,shifts,direction);
end
toc

%% PLOT PARAMETERS

lWidth=2;
gcaOpts = {'box','off','tickdir','out','fontname','Arial','linewidth',lWidth,'fontsize',12};
condColor = colorGen(length(dataSet));
xFine = linspace(5,shifts(end),175);
data.x = shifts;
pInit.t = 20; % may need to be quasi-randomly adjusted when fit doesn't work the first time around; just play with different integers
pInit.b = -2;

performanceLvl_Ax = [.55, 0.75, .9]; % performance levels to determine thresholds
performanceLvl_Dir = [0.35, 0.5, 0.75];
higherLvl = true;

plotLine = true;
    lineOpt = {'o','o-'};
plotL = true; % plot lines that connect axis to point of interest?
exportFigs = false; % export figures as PNG files?

%% WEIBULL CURVEs

figure
subplot(1,2,1)
hold on
for s = 1:length(dataSet)
    data.y = avgCorrectAxis(s,:);
    pInit.g = 0.5;
    pInit.e = performanceLvl_Ax(higherLvl+1);
    [pBest,~] = fit('fitPsychometricFunction',pInit,{'b','t'},data,'Weibull');
    thresholdAx(s) = pBest.t;
    y = Weibull(pBest,xFine);
    g(s) = plot(xFine,y,'-','LineWidth',2,'color',condColor{s});
    plot(data.x,data.y,lineOpt{plotLine+1},'color',condColor{s});
    plot([0 shifts(end)],[0.5 0.5])
    if plotL
        plot([0 thresholdAx(s)],[performanceLvl_Ax(higherLvl+1) performanceLvl_Ax(higherLvl+1)],'color',condColor{s})
        plot([thresholdAx(s) thresholdAx(s)],[0 performanceLvl_Ax(higherLvl+1)],'color',condColor{s})
    end
    name{s} = sprintf('%s, %f',names{s},thresholdAx(s));
end
    title(sprintf('Axis, at performance level %f', pInit.e))
    legend(g,name)
    xlabel('Shift distance (arcmin)')
    ylabel('Proportion correct')
    set(gcf, 'Color', 'w');
    set(gca,gcaOpts{:})
    if exportFigs
        export_fig psy_axis.png
    end

subplot(1,2,2)
hold on
for s = 1:length(dataSet)
    data.y = avgCorrectDir(s,:);
    pInit.g = 0.25;
    pInit.e = performanceLvl_Dir(higherLvl+1);
    [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},data,'Weibull');
    thresholdDir(s) = pBest.t;
    y = Weibull(pBest,xFine);
    h(s) = plot(xFine,y,'-','LineWidth',2,'color',condColor{s});
    plot(data.x,data.y,lineOpt{plotLine+1},'color',condColor{s})
    plot([0 shifts(end)],[0.25 0.25])
    if plotL
        plot([0 thresholdDir(s)],[performanceLvl_Dir(higherLvl+1) performanceLvl_Dir(higherLvl+1)],'color',condColor{s})
        plot([thresholdDir(s) thresholdDir(s)],[0 performanceLvl_Dir(higherLvl+1)],'color',condColor{s})
    end
    name{s} = sprintf('%s, %f',names{s},thresholdDir(s));
end
    title(sprintf('Direction, at performance level %f', pInit.e))
    legend(h,name)
    xlabel('Shift distance (arcmin)')
    ylabel('Proportion correct')
    set(gcf, 'Color', 'w');
    set(gca,gcaOpts{:})
    if exportFigs
        export_fig psy_axdir.png -m7
    end

%% OTHER AXIS PAIRINGS
figure
for s = 1:length(dataSet)
    subplot(1,length(dataSet),s)
    hold on
    for p = 1:size(avgCorrectPairs,1)
        data.y = avgCorrectPairs(p,:,s);
        pInit.g = 0.5;
        pInit.e = performanceLvl_Ax(higherLvl+1);
        [pBest,~] = fit('fitPsychometricFunction',pInit,{'b','t'},data,'Weibull');
        y = Weibull(pBest,xFine);
        plot(xFine,y,'-','LineWidth',2,'color',condColor{p});
        j(p) = plot(shifts,avgCorrectPairs(p,:,s),'o-','color',condColor{p});
        plot([0 shifts(end)],[0.5 0.5],'color','k')
    end
        title(sprintf('Ax pairs: %s',names{s}))
        legend(j,avgCorrectLabels)
        xlabel('Shift distance (arcmin)')
        ylabel('Proportion correct')
        set(gcf, 'Color', 'w');
        set(gca,gcaOpts{:})   
        axis([0 shifts(end) 0 1])
end
    
%% BAR PLOTS FOR 3 THRESHOLDS FOR DIRECTION & AXIS
% calculates different thresholds based on different performance level
% inputs (p.g); this is what goes into the EEG conditions

dispOpt = 'text'; % 'text' | 'bar'; outputs either table in Command Window or bar plots 

for s = 1:length(dataSet)
    for l = 1:length(performanceLvl_Ax)
        pInit.g = 0.5;
        pInit.e = performanceLvl_Ax(l);
        dataAx.y = avgCorrectAxis(s,:);
        dataAx.x = shifts;
        [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},dataAx,'Weibull');
        thresholdAx_all(s,l) = pBest.t;
    end
end
thresholdAx_all = [performanceLvl_Ax; thresholdAx_all];

for s = 1:length(dataSet)
    for l = 1:length(performanceLvl_Dir)
        pInit.g = 0.25;
        pInit.e = performanceLvl_Dir(l);
        dataDir.x = shifts;        
        dataDir.y = avgCorrectDir(s,:);
        [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},dataDir,'Weibull');
        thresholdDir_all(s,l) = pBest.t;
    end
end
if strcmp(dispOpt,'text')
    thresholdDir_all = [performanceLvl_Dir; thresholdDir_all] 
else
    thresholdDir_all = [performanceLvl_Dir; thresholdDir_all];
    
    % bar plots (includes axis thresh)
    figure
    for s = 1:length(dataSet)
        subplot(length(dataSet),2,2*s-1)
            y = thresholdAx_all(s+1,:);
            x = 1:numel(y);
            bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
            for i = 1:numel(y)
                text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
            end
            title(sprintf('Thresholds, axis: %s',names{s}))
            axis([0.5 size(thresholdAx_all,2)+0.5 0 shifts(end)])
            ax = gca;
            for i = 1:size(thresholdAx_all,2)
                ax.XTickLabel{i} = thresholdAx_all(1,i);
            end
            ylabel('Shift (arcmin)')
            xlabel('Performance level')
            set(gca,gcaOpts{:})

        subplot(length(dataSet),2,2*s)
            y = thresholdDir_all(s+1,:);
            x = 1:numel(y);
            bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
            for i = 1:numel(y)
                text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
            end
            title(sprintf('Thresholds, direction: %s',names{s}))
            axis([0.5 size(thresholdAx_all,2)+.5 0 shifts(end)])
            ax = gca;
            for i = 1:size(thresholdDir_all,2)
                ax.XTickLabel{i} = thresholdDir_all(1,i);
            end
            ylabel('Shift (arcmin)')
            xlabel('Performance level')
            set(gca,gcaOpts{:})
    end
end

%% BAR PLOTS: PROPORTION OF TOTAL RESPONSES EACH RESP WAS SELECTED
% Visualizes if any participant favored one response key over the others

figure
for s = 1:length(dataSet)
    subplot(length(dataSet),1,s)
    [proportions] = respCount(allData{:,:,s});
    lab = {'NE','NW','SW','SE','/','\'};
    y = proportions;
    x = 1:numel(y);    
    bar(y,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    for i = 1:numel(y)
        text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
    title(sprintf('Proportion per response: %s',names{s}))
    ax=gca;
    for i = 1:length(y)
        ax.XTickLabel(i) = lab(i);
    end
    axis([0.5 6.5 0 1])
    ylabel('Proportion')
    xlabel('Response categories')
    set(gca,gcaOpts{:})
end

%% INDIVIDUAL DIRECTION ANALYSIS
figure
for s = 1:length(dataSet)
    subplot(2,2,1) % NE
    hold on
        plot(data.x,percIndiv(1,:,s),'o-','color',condColor{s})
        title('NE')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
    subplot(2,2,2) % NW
    hold on
        plot(data.x,percIndiv(2,:,s),'o-','color',condColor{s})
        title('NW')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
    subplot(2,2,3) % SW
    hold on
        plot(data.x,percIndiv(3,:,s),'o-','color',condColor{s})
        title('SW')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
    subplot(2,2,4) % SE
    hold on
        plot(data.x,percIndiv(4,:,s),'o-','color',condColor{s})
        title('SE')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
end
%%
figure
for s = 1:length(dataSet)
    subplot(2,2,1) % 0 deg
    hold on
        plot(data.x,percAxIndiv(1,:,s),'o-','color',condColor{s})
        title('Right shift, axis')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
        axis([0 150 0 100])
    subplot(2,2,2) % 90 deg
    hold on
        plot(data.x,percAxIndiv(2,:,s),'o-','color',condColor{s})
        title('Up shift, axis')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
        axis([0 150 0 100])
    subplot(2,2,3) % 180 deg
    hold on
        plot(data.x,percAxIndiv(3,:,s),'o-','color',condColor{s})
        title('Left shift, axis')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
        axis([0 150 0 100])
    subplot(2,2,4) % 270 deg
    hold on
        plot(data.x,percAxIndiv(4,:,s),'o-','color',condColor{s})
        title('Down shift, axis')
        xlabel('Shift (arcmin)')
        ylabel('Proportion correct')
        set(gca,gcaOpts{:})
        axis([0 150 0 100])
end

%% THRESHOLD BAR PLOTS
figure 
subplot(2,1,1)
    y = [thresholdAx, mean(thresholdAx)];
    x = 1:numel(y);
    bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    for i = 1:numel(y)
        text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
    title('Threshold: 0.55, Axis')
    axis([0.5 length(dataSet)+1.5 0 125])
    ax = gca;
    for i = 1:length(names)
        ax.XTickLabel(i) = names(i);
        ax.XTickLabel(length(names)+1) = {'Mean'};
    end
    ylabel('Shift (arcmin)')
    set(gca,gcaOpts{:})
subplot(2,1,2)
    y = [thresholdDir, mean(thresholdDir)];
    x = 1:numel(y);
    bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    for i = 1:numel(y)
        text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
    title('Threshold: 0.30, 4 directions')
    axis([0.5 length(dataSet)+1.5 0 125])
    ax = gca;
    for i = 1:length(names)
        ax.XTickLabel(i) = names(i);
        ax.XTickLabel(length(names)+1) = {'Mean'};
    end
    ylabel('Shift (arcmin)')
    set(gca,gcaOpts{:})

%% NUMBER OF REJECTED TRIALS PER CONDITION
figure
for s = 1:length(dataSet)
    subplot(length(dataSet),1,s)
    bar(numNansVec(s,:),.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    title('Number of rejected trials per condition')
    axis([0.5 length(numNansVec)+1.5 0 3])
    ax = gca;
    ylabel('Number of trials')
    xlabel('Condition')
    set(gca,gcaOpts{:})
end

%% HISTOGRAM OF TRIAL LENGTHS
edges = [0:0.025:5.1];
figure
for s = 1:length(dataSet)
    subplot(length(dataSet),1,s)
    x = sort(allData(:,3,s));
    histogram(x,edges,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    title(sprintf('%s, trial length',names{s}))
    xlabel('Trial length (s)')
    ylabel('Number of trials') 
    axis([1.5 2.5 0 300])
    set(gca,gcaOpts{:})
end

%% RASTER PLOT OF CORRECT ANSWERS
for s = 1:length(dataSet)
    sorted(:,:,s) = sortrows(allData(:,:,s));
end
numPerDir = length(sorted)/4;
correctResp = [ones(1,numPerDir)*3, ones(1,numPerDir)*5, ones(1,numPerDir), ones(1,numPerDir)*2];
stacked = correctResp;
for s = 1:length(dataSet)
    stacked = cat(1,stacked,sorted(:,2,s)');
end

for i = 1:length(stacked)
    for j = 1:size(stacked,1)
        if stacked(j,i) == 1
            RGB(j,i,1) = 236/255;
            RGB(j,i,2) = 74/255;
            RGB(j,i,3) = 74/255;
        elseif stacked(j,i) == 2
            RGB(j,i,1) = 249/255;
            RGB(j,i,2) = 216/255;
            RGB(j,i,3) = 127/255;
        elseif stacked(j,i) == 3
            RGB(j,i,1) = 1;
            RGB(j,i,2) = 1;
            RGB(j,i,3) = 1;
        elseif stacked(j,i) == 5;
            RGB(j,i,1) = 123/255;
            RGB(j,i,2) = 212/255;
            RGB(j,i,3) = 220/255;
        else
            RGB(j,i,1) = 0;
            RGB(j,i,2) = 0;
            RGB(j,i,3) = 0;
        end
    end
end

figure
    imagesc(RGB)
    title('Answer comparison over time')
    xlabel('Trial')
    ax = gca;
    ax.YTick = [1:3];
    ax.YTickLabel = {'Correct',names{:}};
    ax.XTick = linspace(numPerDir/2,numPerDir*4+numPerDir/2,5);
    ax.XTickLabel = {'Right','Up','Left','Down'};