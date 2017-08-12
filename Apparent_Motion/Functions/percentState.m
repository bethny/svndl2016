function [distro,concatState] = percentState(validCon,validCond,concatData)
distro = zeros(length(validCon),3);

for i = 1:length(validCon)
    validData(:,i) = ~isnan(concatData(:,i));
    validIdx(i) = length(find(validData(:,i) == 1));
    neg(i) = length(find(concatData(1:validIdx(i),i) < -0.3e4));
    zero(i) = length(find(concatData(1:validIdx(i),i) > -0.3e4 & concatData(1:validIdx(i),i) < 0.3e4));
    pos(i) = length(find(concatData(1:validIdx(i),i) > 0.3e4 & concatData(1:validIdx(i),i) < 1e4)); 
    distro(i,1:3) = [neg(i)*100/validIdx(i), zero(i)*100/validIdx(i), pos(i)*100/validIdx(i)];
end
AM = distro(validCon,1);
% AMB = distro(validCon,2);
FLA = distro(validCon,3);

% for i = length(validCon)
%     validCond{i} = num2str(validCon(i));
% end

T = table(AM, FLA, 'RowNames',validCond)
concatState = [AM,FLA];


% old error button press code
%     err = find(concatData(:,i) > 1e4);
%     numValidCycles = size(concatData,1) - size(err,1);