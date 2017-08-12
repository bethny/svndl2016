function [rawData,sorted] = dataFilter(dataFolder,direction,filterTime,timeLimit)
    
%   DESCRIPTION: Filters psychophysical button data according to a set of
%   parameters.

%   INPUT:
%           dataFolder: Filepath for an individual subject.
%           direction: 'cardinal' | 'diagonal'. Optional. Signifies
%                       direction of movement. Defaults to diagonal.
%           filterTime: Logical. Optional; defaults to True. Signifies
%                       whether or not you want to filter based on response time.
%           timeLimit:  Double. Indicates cutoff time (in ms), after which
%                       responses are discarded.
%   OUTPUT:
%           rawData:    n x 3 array with columns for condition, keyboard
%                       response, and trial length

    if nargin < 4 % default: filter all responses after 2.2s
        timeLimit = 2200;
    end
    
    if nargin < 3 % default: filter responses by time
        filterTime = 1;
    end
    
    if nargin < 2 % default: assume stimset has diagonal motion
        direction = 'diagonal';
    end
    
    t=2;
    while exist(sprintf('%s/RTSeg_s00%d.mat', dataFolder,t),'file') == 2; 
        file(t-1) = load(sprintf('%s/RTSeg_s00%d.mat', dataFolder,t));
        t=t+1;
    end
    
    workingCond = [];
    workingResp = [];
    workingTime = [];
    for i = 1:size(file,2)
        workingCond = cat(1,workingCond,file(i).TimeLine.cndNmb);
        workingResp = cat(2,workingResp,file(i).TimeLine.respString);
        workingTime = cat(1,workingTime,file(i).TimeLine.respTimeSec);
    end
    b = workingResp;
    rawData(:,1) = workingCond;
    rawData(:,3) = workingTime;
        
    while i < length(b)                                                                                                 % removing "MIS" inputs & replacing with zeros
        if b(i) == 'M'
            b(i) = '0';                                                                                                                                 
            b(i+1:i+2) = [];
        end
        if b(i) == 'L' || b(i) == 'R'
            b(i) = '0';
            b(i+1) = [];
        end
        i = i+1;
    end   
    
    if strcmp(direction,'diagonal')
        for i = 1:length(b)                                                                                                   % removing non-1,2,3,5 inputs % replacing with zeros
            if b(i) ~= '1' && b(i) ~= '2' && b(i) ~= '4' && b(i) ~= '5'
                b(i) = '0';
            end
        end
    else
        for i = 1:length(b)                                                                                                   % removing non-1,2,3,5 inputs % replacing with zeros
            if b(i) ~= '1' && b(i) ~= '2' && b(i) ~= '3' && b(i) ~= '5'
                b(i) = '0';
            end
        end
    end
    b = str2num(b');
    rawData(:,2) = b;
    
    for i = 1:size(rawData,1)                                                                                                 % replacing all zeros with NaNs & filtering out responses based on response time 
        if filterTime
            if rawData(i,2) == 0 || rawData(i,3) < 1.7 || rawData(i,3) > timeLimit/1000
                rawData(i,2) = NaN;
                rawData(i,3) = NaN;
            end
        else
            if rawData(i,2) == 0 || rawData(i,3) < 1.7
                rawData(i,2) = NaN;
                rawData(i,3) = NaN;
            end
        end
    end 
    
    sorted = sortrows(rawData,1);
    
%     if delByTime
%         for j = 1:length(sorted)
%             if isnan(sorted(j,2))
%                 sorted(j,3) = NaN;
%             end
%         end
%     end
end