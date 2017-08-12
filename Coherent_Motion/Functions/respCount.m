function [proportions] = respCount(rawData)
%   Description:    Returns percent of time participant pressed each button
%
%   In:
%       rawData:    n x 3 array double; Column 1 contains condition number,
%                   Column 2 contains response (either 1, 2, 4, 5, or NaN), Column 3
%                   contains trial timing.
    numTrials = length(rawData);   
    NE = 0;
    NW = 0;
    SW = 0;
    SE = 0;
    for i = 1:numTrials
        if rawData(i,2) == 5
            NE = NE + 1;
        elseif rawData(i,2) == 4
            NW = NW + 1;
        elseif rawData(i,2) == 1
            SW = SW + 1;
        elseif rawData(i,2) == 2
            SE = SE + 1;
        end
    end
    proportions = [NE/numTrials,NW/numTrials,SW/numTrials,SE/numTrials,(NE+SW)/numTrials,(NW+SE)/numTrials];
end

%% OLD CODE FOR WHEN CARDINAL DIRECTIONS WERE AN OPTION
%     if strcmp(direction,'cardinal')
%         R = 0;
%         U = 0;
%         L = 0;
%         D = 0;
%         for i = 1:numTrials
%             if rawData(i,2) == 1
%                 R = R + 1;
%             elseif rawData(i,2) == 2
%                 U = U + 1;
%             elseif rawData(i,2) == 3
%                 L = L + 1;
%             elseif rawData(i,2) == 5
%                 D = D + 1;
%             end
%         end
%         proportions = [R/numTrials,U/numTrials,L/numTrials,D/numTrials,(R+L)/numTrials,(U+D)/numTrials];
%     else