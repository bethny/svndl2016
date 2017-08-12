function maxDiff(data1, data2, dataLabels, dirResData, timeCourseLen, useRLA)
%   Description:    Takes two 128-channel datasets and performs a principle
%                   components analysis to determine components where the two datasets vary
%                   the most.
%
%   Input:
%           data1, data2:   1 x nSubjects cell vector, with dimensions EEG
%                           timecourse x nChannels x nTrials
%
%           dataLabels:     Cell vector with strings to describe each dSet.
%
%           dirResData:     String. Directory where plots will be saved.
%
%           timeCourseLen:  Int. Trial duration in ms.
%
%           useRLA:         Logical. True when plotting RLA, false when
%                           SLA.
%
%   Output:                 2 x 3 subplot with EEG traces and EGI sensor
%                           net maps for 3 components.

    nSubj = size(data1, 1);
    if (~iscell(data1))
        data1 = cell(data1);
    end
    
    if (~iscell(data2))
        data2 = cell(data2);
    end
        
    %get a nanmean
    
    catData1 = cat(3, data1{:});
    muData1 = nanmean(catData1, 3);
    %semData1 = nanstd(catData1, [], 3)/sqrt(size(catData1, 3));   
    semData1 = nanstd(catData1, [], 3)/sqrt(nSubj);   
    

    catData2 = cat(3, data2{:});
    muData2 = nanmean(catData2, 3);
    %semData2 = nanstd(catData2, [], 3)/sqrt(size(catData2, 3));   
    semData2 = nanstd(catData2, [], 3)/sqrt(nSubj);   
        
    [tmp1, tmp2, A, DD, WW] = calcMaxDiff(muData1, muData2);
    
    std_y1 = semData1*WW;
    std_y2 = semData2*WW;
    
    XLA = {'SLA','RLA'};
    hf = figure;
    fullTitle = ['Difference between ' dataLabels{1} ' ' dataLabels{2} ',' XLA{useRLA+1}];
    
    title(fullTitle);
    nc = size(tmp1, 2);
    
    timeCourse = linspace(0, timeCourseLen, size(muData1, 1));

    for c = 1:nc
        subplot(nc, 2, 2*c - 1);
        plot(timeCourse, tmp1(:, c), 'b', 'LineWidth', 2); hold on;
        %h1 = shadedErrorBar(timeCourse,tmp1(:, c), std_y1(:, c), 'b');

        plot(timeCourse, tmp2(:, c), 'r', 'LineWidth', 2);        
        %h2 = shadedErrorBar(timeCourse, tmp2(:, c), std_y2(:, c), 'r');
        legend([dataLabels{:}]'); hold on;
                
        %legend([h1.patch h2.patch]', [dataLabels{:}]'); hold on;
        
        subplot(nc, 2, 2*c);
        plotOnEgi(A(:,c), [], 1);
    end
                                       
    saveas(hf, fullfile(dirResData, fullTitle), 'fig');
%     figure;
%     plot(DD, '*k');
end

function [y1, y2, A, DD, WW] = calcMaxDiff(d1, d2)
    
    diff = d1 - d2;
    c = cov(diff);
    
    c1 = cov(d1);
    c2 = cov(d2);
    cPool = (c1+c2)/2;

	% compute eigenvalues
    [W, D] = eig(c);
    
    DD = diag(D);
    %% keep top three max-dif filters
    nc = 3;
    %WW = W;
    
    WW = W(:, end:-1:end - nc + 1);
    A = cPool*WW*inv(WW'*cPool*WW);  % scalp projections of max-dif filters

    %% project onto data
    y1 = d1*WW;
    y2 = d2*WW;
end
