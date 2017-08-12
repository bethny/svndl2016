%% TEST PLOTS
% close all
% set2plot = {c75_avg, w75_avg};
% half1 = 1:64;
% half2 = 65:128;
% 
% figure
% for i = half1  
%     subplot(8,8,i)
%     hold on
%     plot(set2plot{1}(:,i),'color','b')
%     plot(set2plot{2}(:,i),'color','r')
%     title(sprintf('%d',i))
%     axis([0 1260 -5000 5000])
% end
% 
% figure
% for i = half2
%     subplot(8,8,i-64)
%     hold on
%     plot(set2plot{1}(:,i),'color','b')
%     plot(set2plot{2}(:,i),'color','r')
%     title(sprintf('%d',i))
%     axis([0 1260 -5000 5000])
% end

%% TEST CODE FOR OLD SORTING CODE
% t=2;s=1;c=3;
% dataFolder = sprintf('/Users/bethanyhung/Desktop/Summer_2016/Coherent_Motion/EEG/%s', dataSet{s});
% filePath_raw = sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder, c, t);
% channels = 1:128;

%% OLD SORTING CODE
% for s = 1:length(dataSet)
%     fprintf('Running subject %s\n',dataSet{s});
%     dataFolder = sprintf('/Users/bethanyhung/Desktop/Summer_2016/Coherent_Motion/EEG/%s', dataSet{s});
%     for t = trials % 1-40
%         fprintf('Running rep: %d\n',t);
%         for c = conds %conds       
%             filePath_raw = sprintf('%s/Raw_c%03d_t%03d.mat', dataFolder, c, t);
%             [EEG_zeroed, percentNaN_1, sampRate] = extractRawDataCM(dataFolder, filePath_raw, shift);    
%             percentNaN_128(t,c,s) = percentNaN_1; % percent of raw data that is NaNs            
%             curResp = sortedResp(t,c,s);
%             [answer] = checkResp2(c,curResp);
%             if answer
%                 if c == 1 || c == 4 || c == 7 || c == 10
%                     correct75_1 = nanmean(cat(3,correct75_1,EEG_zeroed),3);
%                 elseif c == 2 || c == 5 || c == 8 || c == 11
%                     correct50_1 = nanmean(cat(3,correct50_1,EEG_zeroed),3);
%                 else
%                     correct150_1 = nanmean(cat(3,correct150_1,EEG_zeroed),3);
%                 end
%             else
%                 if c == 1 || c == 4 || c == 7 || c == 10
%                     wrong75_1 = nanmean(cat(3,wrong75_1,EEG_zeroed),3);
%                 elseif c == 2 || c == 5 || c == 8 || c == 11
%                     wrong50_1 = nanmean(cat(3,wrong50_1,EEG_zeroed),3);
%                 else
%                     wrong150_1 = nanmean(cat(3,wrong150_1,EEG_zeroed),3);
%                 end
%             end
%         end    
%     end
%     c75(:,:,s) = correct75_1;
%     w75(:,:,s) = wrong75_1;
%     c50(:,:,s) = correct50_1;
%     w50(:,:,s) = wrong50_1;
%     c150(:,:,s) = correct150_1;
%     w150(:,:,s) = wrong150_1;
% end
% toc

%% SUBJECT OF INTEREST
% subjectOI = '12aug16_1116'; %  10aug16_0040_dF
% i=1;
% while strcmp(dataSet{i}, subjectOI) == false
%     i = i+1;
% end
% subjIdx = i;

%% ELECTRODE NAMES FOR LEGEND

% else
%     if electrodeNames
%         chanIdx = {'65','70','75','83','90'}; % '76' '77' '84' '90' '91' '96'; % OCC-L & OCC-R ROIs [70 74 75 81 82 83] / 'O1','74','Oz','81','82','O2'\
%     else
%         for a = 1:length(chanROI)
%             chanIdx{a} = num2str(chanROI(a)); 
%         end
%     end
% end

%% SORTED RESPONSES, RESHAPED
%     sortedResp(:,:,s) = reshape(respOnly(:,s),40,[]);

%% JUST FOR DISPLAY (psychometric curves with thresholds as stars)
% x2 = [sort(thresholdDir_all(2,2:3)),150];
% y2 = [0.75, 0.5, 0.2613];
% figure
% hold on
%     data.y = avgCorrectDir;
%     pInit.g = 0.25;
%     pInit.e = 0.5;
%     [pBest,logLikelihoodBest] = fit('fitPsychometricFunction',pInit,{'b','t'},data,'Weibull');
%     thresholdDir = pBest.t;
%     y = Weibull(pBest,xFine);
%     i(1,s) = plot(xFine,y,'-','LineWidth',2,'color',condColor{1});
%     plot(data.x,data.y,'o-','color',condColor{1})
%     i(2,s) = plot(x2,y2,'c*','color',condColor{5});
%         plot([0 54.6701],[0.5 0.5],'color',condColor{5}) % 50%
%         plot([54.6701 54.6701],[0 0.5],'color',condColor{5})
%         
%         plot([0 40.2637],[0.75 0.75],'color',condColor{5}) % 75%
%         plot([40.2637 40.2637],[0 0.75],'color',condColor{5})
%         
%         plot([0 150],[0.2613 0.2613],'color',condColor{5}) % 105
%         plot([150 150],[0 0.2613],'color',condColor{5})
%     name = {sprintf('PK, %f',thresholdDir),'EEG shifts'};
%     title(sprintf('Direction, at performance level %f', pInit.e))
%     legend(i,name)
%     xlabel('Shift distance (arcmin)')
%     ylabel('Proportion correct')
%     set(gcf, 'Color', 'w');
%     set(gca,gcaOpts{:})
%     export_fig psy_dirDemo.png -m7