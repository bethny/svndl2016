clear all;
close all;
codeFolder = '/Users/bethanyhung/code/git/svndl2016/Apparent_Motion/Functions';
addpath(genpath(codeFolder));

fullDataSet = {'6jul16_0037','19jul16_1119'}; % '8jul16_1076', % removed 1076 because not accurately at PSE / '5jul16_1116','14jul16_1003','14jul16_0034',,'8jul16_1076','5jul16_1114'
fullNames = {'0037','1119'}; % '1076','1116','1003','0034',,'1076','1114'
frequency = '2Hz';
AR = '1:7 AR';

for s = 1:length(fullDataSet)
    dataFolder{s} = sprintf('/Users/bethanyhung/Desktop/EVERYTHING/Summer_2016/Apparent Motion non-code/128-Channel-new/%s', fullDataSet{s});
end

cond = 1:3;
trials = 1:16;
seg = 2; % seg you want to look at; generally irrelevant, keep at 2
shift = 0.5; % # of seconds you want to delete from front
epochT = [0.5]; % length of an epoch; [plotting one cycle, FFT]
channels = [1:128];
channels_plot = [76 77 84 90 91 96]; % [65, 70, 75, 83, 90]; % low-channel system [70 74 75 81 82 83]
numTimept = 210;

tic
for s = 1:length(fullDataSet)
    fprintf('Running subject %s\n',fullDataSet{s});
    filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder{s}, seg);
    singleZeroed_1 = nan(numTimept,length(channels_plot),2);  
    singleZeroed_2 = nan(numTimept,length(channels),2);
    for t = 1:length(trials)
        fprintf('Running trial: %d\n',t);       
        for c = 1:length(cond)
            filePaths_raw = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{s}, c, t)};
            [rawDataBTN_1, checkedDataEEG_Zeroed_1, percentNaN_1] = extractRawData(dataFolder{s}, filePaths_raw, channels, filePath_seg, shift);
            rawDataBTN(:,t,c) = rawDataBTN_1; % epoch rejection
            checkedDES_selected_1 = checkedDataEEG_Zeroed_1(:,channels_plot); % minimized single-trial, single-cond version / [25200 5]      
            percentNaN_128(t,c,s) = percentNaN_1; % percent of raw data that is NaNs; represents % thrown out - total num of timepts = 30240 * 128
            sampRate_struct = load(sprintf('/Users/bethanyhung/Desktop/EVERYTHING/Summer_2016/Apparent_Motion/128-Channel-new/%s/Raw_c001_t001.mat',fullDataSet{s}),'FreqHz');
            sampRate = sampRate_struct.FreqHz;
            if c == 2 % epoch sort
                [posZeroed_1,negZeroed_1,~,~] = classifyData128(rawDataBTN_1,checkedDES_selected_1,sampRate,epochT(1),c,singleZeroed_1);
                posZeroed(:,:,t) = posZeroed_1;
                negZeroed(:,:,t) = negZeroed_1;   
                [posZeroed_2,negZeroed_2,~,actualZero_1] = classifyData128(rawDataBTN_1,checkedDataEEG_Zeroed_1,sampRate,epochT(1),c,singleZeroed_2);
                posZeroed_128(:,:,t) = posZeroed_2;
                negZeroed_128(:,:,t) = negZeroed_2; 
                percentZero_128(t,s,c) = actualZero_1/(120*numTimept*length(channels)); % number of zeroes that aren't NaNs; ONLY CONDITION 2; cond 1 and 3 should be FULL 
            else
                [~,~,singleZeroed_1,~] = classifyData128(rawDataBTN_1,checkedDES_selected_1,sampRate,epochT(1),c,singleZeroed_1);
                singleZeroed(:,:,:,t) = singleZeroed_1; % all epoch sorting (pos/neg) is done for each subject
                [~,~,singleZeroed_2] = classifyData128(rawDataBTN_1,checkedDataEEG_Zeroed_1,sampRate,epochT(1),c,singleZeroed_2);
                singleZeroed_128(:,:,:,t) = singleZeroed_2;
                percentZero_128(t,s,c) = 0;
            end
        end
    end
    posZeroed_subj(:,:,:,s) = posZeroed;
    negZeroed_subj(:,:,:,s) = negZeroed;    
    singleZeroed_subj(:,:,:,:,s) = singleZeroed;
    posZeroed_subj_128(:,:,:,s) = posZeroed_128;
    negZeroed_subj_128(:,:,:,s) = negZeroed_128;    
    singleZeroed_subj_128(:,:,:,:,s) = singleZeroed_128;
    rawDataBTN_all(:,:,:,s) = rawDataBTN;
    
end
toc

% data discarded
percentZero_128 = permute(percentZero_128,[1,3,2]);
percentDiscarded = percentNaN_128 + percentZero_128;
percentDiscarded_t = squeeze(mean(percentDiscarded,1));

rawDataBTN_all2 = squeeze(rawDataBTN_all(:,:,2,:)); % only looks at condition2

posZeroed_trialAvg = squeeze(nanmean(posZeroed_subj,3)); % averaging across all trials; still separate subjects
negZeroed_trialAvg = squeeze(nanmean(negZeroed_subj,3));
singleZeroed_trialAvg = squeeze(nanmean(singleZeroed_subj,4));
sum_trialAvg = squeeze(singleZeroed_trialAvg(:,:,1,:) + singleZeroed_trialAvg(:,:,2,:));

posZeroed_trialAvg_128 = squeeze(nanmean(posZeroed_subj_128,3)); % 128-version
negZeroed_trialAvg_128 = squeeze(nanmean(negZeroed_subj_128,3));
singleZeroed_trialAvg_128 = squeeze(nanmean(singleZeroed_subj_128,4));
sum_trialAvg_128 = squeeze(singleZeroed_trialAvg_128(:,:,1,:) + singleZeroed_trialAvg_128(:,:,2,:));

posZeroed_subjAvg = squeeze(nanmean(posZeroed_trialAvg,3)); % averaged across all subjects
negZeroed_subjAvg = squeeze(nanmean(negZeroed_trialAvg,3));
singleZeroed_subjAvg = squeeze(nanmean(singleZeroed_trialAvg,4));

posZeroed_subjAvg_128 = squeeze(nanmean(posZeroed_trialAvg_128,3)); % averaged across all subjects
negZeroed_subjAvg_128 = squeeze(nanmean(negZeroed_trialAvg_128,3));
singleZeroed_subjAvg_128 = squeeze(nanmean(singleZeroed_trialAvg_128,4));

% standard deviation per timepoint across all 5 subjects
pos_trialAvg_SEM = squeeze(std(posZeroed_trialAvg,0,3))./sqrt(length(fullDataSet));
neg_trialAvg_SEM = squeeze(std(negZeroed_trialAvg,0,3))./sqrt(length(fullDataSet));
single_trialAvg_SEM = squeeze(std(singleZeroed_trialAvg,0,4))./sqrt(length(fullDataSet));
sum_trialAvg_SEM = squeeze(std(sum_trialAvg,0,3))./sqrt(length(fullDataSet));

%% PLOTTING EEG TRACES, AVERAGED OVER EPOCH & TRIAL / OPTIMIZED
tic
subjectOI = '19jul16_1119'; % '6jul16_0037','5jul2016_1116','14jul2016_1003','14jul16_0034','19jul16_1119'
what2plot = 'avg';

i=1;
while strcmp(fullDataSet{i}, subjectOI) == false
    i = i+1;
end
subjIdx = i;

posZeroed_indivSubj = posZeroed_trialAvg(:,:,subjIdx); % the one subject you want to inspect
negZeroed_indivSubj = negZeroed_trialAvg(:,:,subjIdx);
singleZeroed_indivSubj = singleZeroed_trialAvg(:,:,:,subjIdx);

numTimept = floor(sampRate*epochT(1)); % 210 per epoch 
lWidth = 1.5; fSize = 10;
gcaOpts1 = {'XTick',linspace(0,numTimept,6),'XTickLabel',{'0','100','200','300','400','500'},'XLim',[0 numTimept],'YLim',[-400 400],'box','off','tickdir','out','fontname','Helvetica','linewidth',lWidth,'fontsize',fSize};
green = [0 195 0]/255;
red25 = [255 191 191]/255; blue25 = [191 191 255]/255; green25 = [191 255 191]/255;

% chanIdx = {'PO7','O1','Oz','O2','PO8'}; % low-channel system
chanIdx = {'76' '77' '84' '90' '91' '96'}; % OCC-L & OCC-R ROIs [70 74 75 81 82 83] / 'O1','74','Oz','81','82','O2'

if strcmp(what2plot,'both')
    lineStyle = '--';
else
    lineStyle = '-';
end

for h = 1:length(chanIdx)
    left_indiv(h) = {singleZeroed_indivSubj(:,h,1)};
    left_avg(h) = {singleZeroed_subjAvg(:,h,1)};
    left_SEM_upper(h) = {singleZeroed_subjAvg(:,h,1) + single_trialAvg_SEM(:,h,1)};
    left_SEM_lower(h) = {singleZeroed_subjAvg(:,h,1) - single_trialAvg_SEM(:,h,1)};

    ambPos_indiv(h) = {posZeroed_indivSubj(:,h)};
    ambPos_avg(h) = {posZeroed_subjAvg(:,h)};
    ambPos_SEM_upper(h) = {posZeroed_subjAvg(:,h) + pos_trialAvg_SEM(:,h)};
    ambPos_SEM_lower(h) = {posZeroed_subjAvg(:,h) - pos_trialAvg_SEM(:,h)};

    ambNeg_indiv(h) = {negZeroed_indivSubj(:,h)};
    ambNeg_avg(h) = {negZeroed_subjAvg(:,h)};
    ambNeg_SEM_upper(h) = {negZeroed_subjAvg(:,h) + neg_trialAvg_SEM(:,h)};
    ambNeg_SEM_lower(h) = {negZeroed_subjAvg(:,h) - neg_trialAvg_SEM(:,h)};

    right_indiv(h) = {singleZeroed_indivSubj(:,h,2)};
    right_avg(h) = {singleZeroed_subjAvg(:,h,2)};
    right_SEM_upper(h) = {singleZeroed_subjAvg(:,h,2) + single_trialAvg_SEM(:,h,2)};
    right_SEM_lower(h) = {singleZeroed_subjAvg(:,h,2) - single_trialAvg_SEM(:,h,2)};

    sum_indiv(h) = {singleZeroed_indivSubj(:,h,1)+singleZeroed_indivSubj(:,h,2)};
    sum_avg(h) = {singleZeroed_subjAvg(:,h,1)+singleZeroed_subjAvg(:,h,2)};
    sum_SEM_upper(h) = {singleZeroed_subjAvg(:,h,1)+singleZeroed_subjAvg(:,h,2)+sum_trialAvg_SEM(:,h)};
    sum_SEM_lower(h) = {singleZeroed_subjAvg(:,h,1)+singleZeroed_subjAvg(:,h,2)-sum_trialAvg_SEM(:,h)};
end
toc

close all
figure
for h = 1:length(chanIdx)
    subplot(length(chanIdx),5,1+5*(h-1))
        hold on
        if strcmp(what2plot,'indivSubj')       
            plot(left_indiv{h},'color','r')
        elseif strcmp(what2plot,'avg')
            shadedEB(left_SEM_upper{h},left_SEM_lower{h},red25)
            plot(left_avg{h},lineStyle,'color','r')
%             plot([183 183],[-400 400],'color','r');
        end
        title(sprintf('FLA, Left Patch, %s',chanIdx{h}))
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(length(chanIdx),5,2+5*(h-1))  
        hold on
        if strcmp(what2plot,'indivSubj')
            plot(ambPos_indiv{h},'color','r')  
            plot(ambNeg_indiv{h},'color','b') 
        elseif strcmp(what2plot,'avg')
            shadedEB(ambPos_SEM_upper{h},ambPos_SEM_lower{h},red25)
            shadedEB(ambNeg_SEM_upper{h},ambNeg_SEM_lower{h},blue25)
            plot(ambPos_avg{h},lineStyle,'color','r')
            plot(ambNeg_avg{h},lineStyle,'color','b')
%             plot([55 55],[-400 400],'color','b');
%             plot([57 57],[-400 400],'color','r');
%             plot([65+105 65+105],[-400 400],'color','b');
%             plot([66+105 66+105],[-400 400],'color','r');
%             plot([61 61],[-400 400],'color','g');
%             plot([171 171],[-400 400],'color','g');
        end
        title(sprintf('AM, FLA bistable, %s',chanIdx{h}))
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(length(chanIdx),5,3+5*(h-1))
        hold on
        if strcmp(what2plot,'indivSubj')         
            plot(right_indiv{h},'color','r')
        elseif strcmp(what2plot,'avg')
            shadedEB(right_SEM_upper{h},right_SEM_lower{h},red25)
            plot(right_avg{h},lineStyle,'color','r')
%             plot([57 57],[-400 400],'color','r');
        end
        title(sprintf('FLA, Right Patch, %s',chanIdx{h}))
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(length(chanIdx),5,4+5*(h-1))        
        hold on
        if strcmp(what2plot,'indivSubj')
            plot(sum_indiv{h},'color',color4)
        elseif strcmp(what2plot,'avg')
            shadedEB(sum_SEM_upper{h},sum_SEM_lower{h},green25)
            plot(sum_avg{h},lineStyle,'color',green)
%             plot([61 61],[-400 400],'color','g');
%             plot([171 171],[-400 400],'color','g');
        end
        title(sprintf('Linear combination, %s',chanIdx{h}))
        ax = gca;
        set(gca,gcaOpts1{:})
    subplot(length(chanIdx),5,5+5*(h-1)) 
        hold on
        if strcmp(what2plot,'indivSubj')
            plot(sum_indiv{h},'color',color4)
            plot(ambPos_indiv{h},'color','r')  
            plot(ambNeg_indiv{h},'color','b')
        elseif strcmp(what2plot,'avg')
            plot(sum_avg{h},lineStyle,'color',green)  
            plot(ambPos_avg{h},lineStyle,'color','r')
            plot(ambNeg_avg{h},lineStyle,'color','b')     
        end
        title(sprintf('Comparison, %s',chanIdx{h}))
        ax = gca;
        set(gca,gcaOpts1{:})
end

%% timepoint picking / electrode maps
for a = 1
mot_subjAvg(:,:,1) = posZeroed_subjAvg; % mot_subjAvg is equivalent to singleZeroed_subjAvg
mot_subjAvg(:,:,2) = negZeroed_subjAvg;
mot_subjAvg_split(:,:,:,1) = mot_subjAvg(1:numTimept/2,:,:); % 4D: timept channel AM/FLA halves
mot_subjAvg_split(:,:,:,2) = mot_subjAvg(numTimept/2+1:end,:,:);
mot_subjAvg_128(:,:,1) = posZeroed_subjAvg_128;
mot_subjAvg_128(:,:,2) = negZeroed_subjAvg_128;

sum_subjAvg = singleZeroed_subjAvg(:,:,1) + singleZeroed_subjAvg(:,:,2);
sum_subjAvg_split(:,:,1) = sum_subjAvg(1:numTimept/2,:); % 3D: timept channel halves
sum_subjAvg_split(:,:,2) = sum_subjAvg(numTimept/2+1:end,:);
sum_subjAvg_128 = singleZeroed_subjAvg_128(:,:,1) + singleZeroed_subjAvg_128(:,:,2);

[data_LR,avgPeakIdx_LR] = pickTimepoints(singleZeroed_subjAvg,singleZeroed_subjAvg_128); % [128 2]; 2nd dim is left/right
[data_Mot,avgPeakIdx_Mot] = pickTimepoints_split(mot_subjAvg_split,mot_subjAvg_128); % [128 2]; 2nd dim is pos/neg
[data_Sum,avgPeakIdx_Sum] = pickTimepoints_split(sum_subjAvg_split,sum_subjAvg_128); % [128 1]

data_MotvsSum_L = mot_subjAvg_128(61,:,1);
data_SumvsMOT_L = sum_subjAvg_128(61,:);
data_MotvsSum_R = mot_subjAvg_128(171,:,1);
data_SumvsMOT_R = sum_subjAvg_128(171,:);
end % also just to collapse this thing

[colorbarLimits_LR] = genColorbar(data_LR(:,1),data_LR(:,2));
[colorbarLimits_Mot_h1] = genColorbar(data_Mot(:,1,1),data_Mot(:,2,1)); % x1 and x2 will be the pos and neg
[colorbarLimits_Mot_h2] = genColorbar(data_Mot(:,1,2),data_Mot(:,2,2));
[colorbarLimits_Mot_diff] = genColorbar(data_Mot(:,2,1)-data_Mot(:,1,1),data_Mot(:,2,2)-data_Mot(:,1,2));
[colorbarLimits_SumvsMot_L] = genColorbar(data_MotvsSum_L,data_SumvsMOT_L);
[colorbarLimits_SumvsMot_R] = genColorbar(data_MotvsSum_R,data_SumvsMOT_R);
[colorbarLimits_SumvsMot_diff] = genColorbar(data_SumvsMOT_L-data_MotvsSum_L,data_SumvsMOT_R-data_MotvsSum_R);

labels_LR = {'Left','Right'};
labels_Mot = {'AM','FLA'};
labels_lin = {'AM','Sum'};

showColorbar = true;

%% LEFT vs RIGHT Indiv Patches
figure % left and right individual patches
for i = 1:2
    subplot(1,2,i)
    plotH = plotOnEgi(data_LR(:,i),colorbarLimits_LR,showColorbar);
    colormap('cool');
    curPos = get(get(plotH,'parent'),'position');
    curPos(3) = curPos(3)*1.05;
    c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
    set(c,'position',[.5 .25 .01 .5]);
    set(get(plotH,'parent'),'position',curPos);
    title(sprintf('%s individual patch at peak',labels_LR{i}))
end

%% AM vs FLA 
figure % AM left, fla & AM
for i = 1:2
    subplot(1,2,i)
        plotH = plotOnEgi(data_Mot(:,i,1),colorbarLimits_Mot_h1,showColorbar);
        colormap('cool');
        curPos = get(get(plotH,'parent'),'position');
        curPos(3) = curPos(3)*1.05;
        c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
        set(c,'position',[.5 .25 .01 .5]);
        set(get(plotH,'parent'),'position',curPos);
        title(sprintf('Ambiguous cond.: %s, left peak',labels_Mot{i}))  
end
figure % AM right, fla & AM
for i = 1:2
    subplot(1,2,i)
        plotH = plotOnEgi(data_Mot(:,i,2),colorbarLimits_Mot_h2,showColorbar);
        colormap('cool');
        curPos = get(get(plotH,'parent'),'position');
        curPos(3) = curPos(3)*1.05;
        c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
        set(c,'position',[.5 .25 .01 .5]);
        set(get(plotH,'parent'),'position',curPos);
        title(sprintf('Ambiguous cond.: %s, right peak',labels_Mot{i}))
end
figure % FLA minus AM
for i = 1:2
    subplot(1,2,i)
        plotH = plotOnEgi(data_Mot(:,2,i)-data_Mot(:,1,i),colorbarLimits_Mot_diff,showColorbar);
        colormap('cool');
        curPos = get(get(plotH,'parent'),'position');
        curPos(3) = curPos(3)*1.05;
        c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
        set(c,'position',[.5 .25 .01 .5]);
        set(get(plotH,'parent'),'position',curPos);
        title(sprintf('FLA - AM difference, %s peak',labels_LR{i}))
end   

%% AM vs linear prediction
SvM_LR = {data_MotvsSum_L, data_SumvsMOT_L; data_MotvsSum_R, data_SumvsMOT_R};
figure % left peak
for i = 1:2
    subplot(1,2,i)
        plotH = plotOnEgi(SvM_LR{1,i},colorbarLimits_SumvsMot_L,showColorbar);
        colormap('cool');
        curPos = get(get(plotH,'parent'),'position');
        curPos(3) = curPos(3)*1.05;
        c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
        set(c,'position',[.5 .25 .01 .5]);
        set(get(plotH,'parent'),'position',curPos);
        title(sprintf('%s at AM-Sum avg timept, left peak',labels_lin{i}))
end

figure % right peak
for i = 1:2
    subplot(1,2,i)
        plotH = plotOnEgi(SvM_LR{2,i},colorbarLimits_SumvsMot_R,showColorbar);
        colormap('cool');
        curPos = get(get(plotH,'parent'),'position');
        curPos(3) = curPos(3)*1.05;
        c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
        set(c,'position',[.5 .25 .01 .5]);
        set(get(plotH,'parent'),'position',curPos);
        title(sprintf('%s at AM-Sum avg timept, right peak',labels_lin{i}))
end  

figure % difference (linear prediction minus AM)
for i = 1:2
    subplot(1,2,i)
        plotH = plotOnEgi(SvM_LR{i,2} - SvM_LR{i,1},colorbarLimits_SumvsMot_diff,showColorbar);
        colormap('cool');
        curPos = get(get(plotH,'parent'),'position');
        curPos(3) = curPos(3)*1.05;
        c= colorbar('location','EastOutside','fontsize',12,'fontname','Arial');
        set(c,'position',[.5 .25 .01 .5]);
        set(get(plotH,'parent'),'position',curPos);
        title(sprintf('Sum-AM diff. at AM&Sum avg timept, %s peak',labels_LR{i}))
end

%% percent good epochs (across condition, channel, subject) / OPTIMIZED
lWidth = 2;
fSize = 12;
gcaOpts = {'box','off','tickdir','out','fontname','Arial','linewidth',lWidth,'fontsize',fSize};

for s = 1:length(fullDataSet) 
    for t = 1:length(trials)
        for c = 1:length(cond)
            filePaths_raw = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{s}, c, t)};
            [percentOK] = percentageOK(filePaths_raw,channels);
            percentOK_channel(:,t,c,s) = percentOK;
        end
    end
end

percentOK_avg1 = squeeze(nanmean(percentOK_channel,1)); % averaged over all channels
percentOK_avg2 = squeeze(nanmean(percentOK_avg1,1)); % averaged over all channels + trials
percentOK_avg3_Subj = nanmean(percentOK_avg2,1); % averaged over all channels + trials + conditions
percentOK_avg3_Cond = nanmean(percentOK_avg2,2)'; % averaged over all channels + trials + subjects
percentOK_avg11 = squeeze(nanmean(percentOK_channel,2)); % averaged over all trials
percentOK_avg21 = squeeze(nanmean(percentOK_avg11,2)); % averaged over all trials + conditions
percentOK_avg31 = squeeze(nanmean(percentOK_avg21,2))'; % averaged over all trials + conditions + subjects
grandAvg = nanmean(percentOK_avg3_Subj); % averaged over all channels + trials + conditions + subjects

figure
    subplot(2,2,1)
        y = [percentOK_avg3_Subj, grandAvg];
        x = [1:numel(y)];
        bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
        for i = 1:numel(y)
            text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
        end
        title(sprintf('Percent Epoch OK, avg per subject'))
        axis([0.5 length(fullDataSet)+1.5 0 1])
        ax = gca;
        for i = 1:length(fullDataSet)
            ax.XTickLabel(i) = {fullNames{i}};
            ax.XTickLabel(length(fullDataSet)+1) = {'Mean'};
        end
        ylabel('Percent Epoch OK')
        set(gca,gcaOpts{:})
    
    subplot(2,2,2)
        y = [percentOK_avg3_Cond, grandAvg];
        x = [1:numel(y)];
        bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
        for i = 1:numel(y)
            text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
        end
        title(sprintf('Percent Epoch OK, avg per condition'))
        axis([0.5 length(cond)+1.5 0 1])
        ax = gca;
        for i = 1:length(cond)
            ax.XTickLabel(i) = {cond(i)};
            ax.XTickLabel(length(cond)+1) = {'Mean'};
        end
        ylabel('Percent Epoch OK')
        set(gca,gcaOpts{:})
    
    subplot(2,2,[3,4])
        y = [percentOK_avg31, grandAvg];
        bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
        title(sprintf('Percent Epoch OK, avg per channel'))
        axis([0.5 length(channels)+1.5 0 1])
        ax = gca;
        ylabel('Percent Epoch OK')
        set(gca,gcaOpts{:})
        
%% data rejected
close all
gcaOpts_3 = {'box','off','tickdir','out','fontname','Arial','linewidth',2,'fontsize',12,'YLim',[0 1]};
for c = 1:length(cond)
    subplot(3,1,c)
    y = [squeeze(percentDiscarded_t(c,:)),mean(squeeze(percentDiscarded_t(c,:)))];
    x = [1:numel(y)];
    bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    for i = 1:numel(y)
        text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
    title(sprintf('Cond. %d',c))  
    ax=gca;
    ylabel('% data discarded')
    axis([0.5 length(fullDataSet)+1.5 0 1])
    for i = 1:length(fullDataSet)
        ax.XTickLabel(i) = fullNames(i);
        ax.XTickLabel(length(fullDataSet)+1) = {'Mean'};
    end
    set(gca,gcaOpts_3{:})
end   

%% PERCENT APPARENT MOTION / OPTIMIZED
[AM] = percentStateMult(rawDataBTN_all2);

lWidth = 2;
fSize = 12;
gcaOpts = {'box','off','tickdir','out','fontname','Arial','linewidth',lWidth,'fontsize',fSize};

figure
    y = [AM, mean(AM)];
    x = [1:numel(y)];
    bar(y,.6,'FaceColor',[123/255 212/255 220/255],'EdgeColor',[0 0 0],'LineWidth',0.1)
    for i = 1:numel(y)
        text(x(i),y(i),num2str(y(i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
    title(sprintf('Proportion AM at %s, %s', frequency, AR))
    axis([0.5 length(fullDataSet)+1.5 0 100])
    ax = gca;
    for i = 1:length(fullNames)
        ax.XTickLabel(i) = {fullNames{i}};
        ax.XTickLabel(length(fullNames)+1) = {'Mean'};
    end
    ylabel('Percent Apparent Motion')
    set(gca,gcaOpts{:})

%% RASTER PLOTS / OPTIMIZED
[RGBMat] = rasterizeData128(rawDataBTN_all2);

figure
for s = 1:length(fullDataSet)
    subplot(1,length(fullDataSet),s)
    imagesc(RGBMat(:,:,:,s))
    title(sprintf('%s, %s, %s',fullNames{s},frequency,AR))
    ax = gca;
    ax.XTick = linspace(0,size(rawDataBTN_all2,1),7);
    ax.XTickLabel = {'60','10','20','30','40','50'};
    ylabel('Trials')
    xlabel('Time (sec)')
    set(gca,gcaOpts{:})
end
%% FAST FOURIER TRANSFORM / NEEDS TO BE FIXED

[epochsEEG,~] = cutEpochs(rawDataBTN,rawDataEEG,sampRate,epochT(2));
avgedEpoch = squeeze(nanmean(epochsEEG,2));
% cutIdx = 30;

power = false;
[pCut, realFreqCut] = temp2spec2(sampRate, avgedEpoch, power); 

xMax = 30;
figure
for c = 1:length(condNames)
    for h = 1:size(avgedEpoch,3)
        subplot(length(condNames),size(avgedEpoch,3), c+(h-1)*5)
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

%% scrap code for debugging
s=3;
t=2;
c=2;

filePath_seg = sprintf('%s/RTSeg_s00%d.mat', dataFolder{s}, seg);
singleZeroed_1 = nan(numTimept,length(channels_plot),2);
filePaths_raw = {sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder{s}, c, t)};
[rawDataBTN_1, checkedDataEEG_Zeroed_1] = extractRawData(dataFolder{s}, filePaths_raw, channels, filePath_seg, shift); % checked 3:40 PM 7/21; should work perfectly
figure
plot(rawDataBTN_1)  

checkedDES_selected_1 = checkedDataEEG_Zeroed_1(:,channels_plot); % minimized single-trial, single-cond version / [25200 5]
figure
for i=1:5
    subplot(5,1,i)
    plot(checkedDES_selected_1(:,i)) % looks good 
end

% epoch sort
sampRate_struct = load(sprintf('/Users/bethanyhung/Desktop/Summer_2016/EEG_Data/128-Channel-new/%s/Raw_c001_t001.mat',fullDataSet{s}),'FreqHz');
sampRate = sampRate_struct.FreqHz;
[posZeroed_1,negZeroed_1,~] = classifyData128(rawDataBTN_1,checkedDES_selected_1,sampRate,epochT(1),c,singleZeroed_1);
 
figure
for i=1:5
    subplot(5,2,2*i-1)
    plot(negZeroed_1(:,i)) % looks good
    subplot(5,2,2*i)
    plot(posZeroed_1(:,i))
end