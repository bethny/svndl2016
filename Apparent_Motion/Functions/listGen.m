function epochIdx = listGen(numTimept,numEpochTotal)    
epochIdx = []; 
for i = 1:numEpochTotal
    if numEpochTotal == 1
        epochIdx = ones(numTimept,1);
    else
        epochIdx = [epochIdx; listGen(numTimept,numEpochTotal-1)+1];
    end
end
end

% you want to add together lists of integers