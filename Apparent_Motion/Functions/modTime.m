function [timeCut, timeConcatCut] = modTime(Fs, xTime1, xTime2, timeConcat)

    timeConcatCut = timeConcat(Fs*xTime1+1:Fs*xTime2,:,:);
    timeCut = linspace(xTime1,xTime2,size(timeConcatCut,1))';

end