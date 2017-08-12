function [correct,wrong] = checkResp(c,curResp,untrimmedEEG_Zeroed_1,chanROI)

    if nargin < 4
        chanROI = 1:128;
    end
    
    if c == 1 || c == 2 || c == 3 
        if curResp == 5
            correct = untrimmedEEG_Zeroed_1(:,chanROI);
            wrong = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        else
            wrong = untrimmedEEG_Zeroed_1(:,chanROI);
            correct = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        end
    elseif c == 4 || c == 5 || c == 6
        if curResp == 4
            correct = untrimmedEEG_Zeroed_1(:,chanROI);
            wrong = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        else
            wrong = untrimmedEEG_Zeroed_1(:,chanROI);
            correct = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        end
    elseif c == 7 || c == 8 || c == 9
        if curResp == 1
            correct = untrimmedEEG_Zeroed_1(:,chanROI);
            wrong = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        else
            wrong = untrimmedEEG_Zeroed_1(:,chanROI);
            correct = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        end
    elseif c == 10 || c == 11 || c == 12
        if curResp == 2
            correct = untrimmedEEG_Zeroed_1(:,chanROI);
            wrong = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        else
            wrong = untrimmedEEG_Zeroed_1(:,chanROI);
            correct = nan(size(untrimmedEEG_Zeroed_1(:,chanROI)));
        end
    end
end