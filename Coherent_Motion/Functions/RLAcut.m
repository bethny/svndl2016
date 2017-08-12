function data_RLA = RLAcut(data_SLA,sampRate,trialInfo,trialIdx)

clear data_RLA

numTpS = floor(sampRate);
%time1 = trialInfo(:,5);
%time2 = trialInfo(:,6);

%timept1 = floor(numTpS*time1)+1;
%timept2 = floor(numTpS*time2);

for i = 1:length(data_SLA)
    data = data_SLA{i};
    idx = trialIdx{i};
    %curTP1 = timept1(idx);
    %curTP2 = timept2(idx);
        for j = 1:length(idx)
            curInfo = trialInfo(idx(j),:);
            start = floor(numTpS*curInfo(5))+1;
            last = floor(numTpS*curInfo(6));
%             if last > 1260
%                 truncData(:,:,j) = nan(630,size(data,2));
%             else
            data_RLA{i}(:,:,j) = data(start:last,:,j);
%             end
        end
end
end

%% TEST CODE
% x = 0;
% for i = 1:length(trialInfo)
%     if ~isnan(trialInfo(i,2)) && trialInfo(i,3)
%         x = x+1;
%     end
% end

% x = 446, meaning that 34 trials were thrown out due to IsEpochOK
% but 471 total trials are found in data_SLA 