function [AM] = percentStateMult(rawData)
    
    timeConcat = reshape(rawData,size(rawData,1)*size(rawData,2),size(rawData,3),size(rawData,4));   
    numSubj = size(timeConcat,3);
    numCond = size(timeConcat,2);
    
    for s = 1:numSubj
        for c = 1:numCond
            validData(:,c,s) = ~isnan(timeConcat(:,c,s));
            validIdx(c,s) = length(find(validData(:,c,s) == 1));
            neg(c,s) = length(find(timeConcat(1:validIdx(c,s),c,s) < -0.3e4));
            zero(c,s) = length(find(timeConcat(1:validIdx(c,s),c,s) > -0.3e4 & timeConcat(1:validIdx(c,s),c,s) < 0.3e4));
            pos(c,s) = length(find(timeConcat(1:validIdx(c,s),c,s) > 0.3e4 & timeConcat(1:validIdx(c,s),c,s) < 1e4)); 
            remZero(c,s) = validIdx(c,s) - zero(c,s);
            distro(:,c,s) = [neg(c,s)*100./remZero(c,s), pos(c,s)*100./remZero(c,s)];  
        end
    end
    AM = squeeze(distro(1,:,:));
end

% old error button press code
%     err = find(concatData(:,i) > 1e4);
%     numValidCycles = size(concatData,1) - size(err,1);

%     distro(i,1:3) = [neg(i)*100/validIdx(i), zero(i)*100/validIdx(i), pos(i)*100/validIdx(i)]; % removing the zeros