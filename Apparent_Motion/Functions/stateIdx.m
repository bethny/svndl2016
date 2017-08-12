function [AM] = stateIdx(timeConcat)

    nSubs = size(timeConcat,2);
    nConds = size(timeConcat,3);
    condLabels = arrayfun(@(x) {num2str(x)}, 1:nConds);
    
    for c = 1:nConds
        for s = 1:nSubs
            validData(:,c,s) = ~isnan(timeConcat(:,s,c));
            validIdx(c,s) = length(find(validData(:,c,s) == 1));
            neg(c,s) = length(find(timeConcat(1:validIdx(c,s),s,c) < -0.3e4));
            zero(c,s) = length(find(timeConcat(1:validIdx(c,s),s,c) > -0.3e4 & timeConcat(1:validIdx(c,s),s,c) < 0.3e4));
            pos(c,s) = length(find(timeConcat(1:validIdx(c,s),s,c) > 0.3e4 & timeConcat(1:validIdx(c,s),s,c) < 1e4)); 
            completeIdx(c,:,s) = cat(2,neg(c,s),zero(c,s),pos(c,s));
            remZero(c,s) = validIdx(c,s) - zero(c,s);
            distro(c,:,s) = [neg(c,s)*100./remZero(c,s), pos(c,s)*100./remZero(c,s)];
        end
    end
    
    for s = 1:nSubs
        AM(:,s) = distro(:,1,s);
%         FLA(:,s) = distro(:,2,s);
%         T = table(AM(:,s),FLA(:,s),'RowNames',condLabels);
%         T.Properties.VariableNames = {'AM' 'FLA'}
    end
    
end

% old error button press code
%     err = find(concatData(:,i) > 1e4);
%     numValidCycles = size(concatData,1) - size(err,1);

%     distro(i,1:3) = [neg(i)*100/validIdx(i), zero(i)*100/validIdx(i), pos(i)*100/validIdx(i)]; % removing the zeros