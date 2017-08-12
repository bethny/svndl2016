function [correct75,correct50,correct150,wrong75,wrong50,wrong150] = sortEEG(trialInfo,...
    EEG_0ed)

    c = trialInfo(1);    
    if trialInfo(2)
        if c == 1 || c == 4 || c == 7 || c == 10
            correct75 = EEG_0ed;
        elseif c == 2 || c == 5 || c == 8 || c == 11
            correct50 = EEG_0ed;
        else
            correct150 = EEG_0ed;
        end
    else
        if c == 1 || c == 4 || c == 7 || c == 10
            wrong75 = EEG_0ed;
        elseif c == 2 || c == 5 || c == 8 || c == 11
            wrong50 = EEG_0ed;
        else
            wrong150 = EEG_0ed;
        end
    end
    
end