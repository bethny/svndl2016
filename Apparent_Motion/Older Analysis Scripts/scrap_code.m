    % TO DO
%     % (a) concatenate trials together within condition
    % (b) for each time point, identify state, generate idx
    % (c) generate new idx, identifying epoch number, across trials
    % (d) pre-generat variables
    %       aggrData = zeros(numT,numChannels,numStates,numConds);
    %       stateCount = zeros(numStates,numConds)
    % (d) loop over epochs, select the current epoch, classify:
            % for e = 1:numEpochs
                % curData = data(epochIdx == e,:,condition);
                % curButton = buttonIdx(epochIdx == e);
                % clfState = output of classification procedure, state?
                % agrrData(:,:,clfState, condition) = agrrData(:,:,clfState, condition)+curData;
                % stateCount(clfState,c) = stateCount(clfState,c)+1;
            % end
            % meanData = agrrData./stateCount




%         stateIdxNeg{:,c} = find(timeConcatBTN(:,c) < -0.3e4); % indices of all NEGATIVE states  
%         stateIdxZero{:,c} = find(timeConcatBTN(:,c) > -0.3e4 & timeConcatBTN(:,c) < 0.3e4); 
%         stateIdxPos{:,c} = find(timeConcatBTN(:,c) > 0.3e4 & timeConcatBTN(:,c) < 1e4); % use like stateIdxNeg{3}(1:20,1)

%             curDataEEG(:,:,c) = timeConcatEEG((epochIdx == e) ,:,c); % currently working with only the data in the epoch defined by e
%             curDataBTN(:,c) = timeConcatBTN(find(epochIdx == e)',c);
            % stateIdx... gives you the indices; now find those within this
            % epoch
            
            %     posEEG_1 = epochsEEG(:,posEpoch{1},:,1);
%     posEEG_2 = epochsEEG(:,posEpoch{2},:,2);
%     posEEG_3 = epochsEEG(:,posEpoch{3},:,3);
    
%     posEEG_1 = [216 0 5]
%     posEEG_2 = [216 468 5]
%     posEEG_3 = [216 575 5]
%     
%     zeroEEG_1 = [216 0 5]
%     zeroEEG_2 = [216 23 5]
%     zeroEEG_3 = [216 2 5]
%     
%     negEEG_1 = [216 600 5]
%     negEEG_2 = [216 709 5]
%     negEEG_3 = [216 23 5]



    
    posEEG = []; negEEG = []; zeroEEG = [];
    
    for c = 1:numCond-2 % don't need to loop over last two conditions... save some time
        for h = 1:numChan
            for e = 1:numEpochTotal
                curIdxEEG = timeConcatEEG(epochIdx == e,:,c); % all the EEG values for that one epoch/ALL 5 CHAN/one cond %%%%%%%%%%%%%%%%%%
%                 classifiedEEG = nan(numTimept,numEpochTotal,3,numChan,numCond);
                if classifiedEpoch(e,c) == 1
                    posEEG = cat(3,posEEG,curIdxEEG);
%                     classifiedEEG(:,e,1,h,c) = curIdxEEG; % 1 = pos, 2 = zero, 3 = neg
                elseif classifiedEpoch(e,c) == 0
%                     classifiedEEG(:,e,2,h,c) = curIdxEEG;
                    zeroEEG = cat(3,zeroEEG,curIdxEEG);
                else
%                     classifiedEEG(:,e,3,h,c) = curIdxEEG;
                    negEEG = cat(3,negEEG,curIdxEEG);
                end
            end
        end
    end
    
    %% old looping
    
        for c = 1:numCond
        for s = 1:numSubj
            for t = 1:numTrial

                for i = 1:numEpoch
                    neg(i,t,s,c) = length(find(epochsBTN(:,i,t,s,c) < -0.3e4)); % # of neg for each epoch
                    zero(i,t,s,c) = length(find(epochsBTN(:,i,t,s,c) > -0.3e4 & epochsBTN(:,i,t,s,c) < 0.3e4)); % # 0 for each epoch
                    pos(i,t,s,c) = length(find(epochsBTN(:,i,t,s,c) > 0.3e4 & epochsBTN(:,i,t,s,c) < 1e4)); % # pos for each epoch
                    percentNeg(i,t,s,c) = neg(i,t,s,c)/(neg(i,t,s,c)+zero(i,t,s,c)+pos(i,t,s,c)); % size = [120 5 1 5]; % of each state in each epoch
                    percentZero(i,t,s,c) = zero(i,t,s,c)/(neg(i,t,s,c)+zero(i,t,s,c)+pos(i,t,s,c)); % 1 row per epoch x trial
                    percentPos(i,t,s,c) = pos(i,t,s,c)/(neg(i,t,s,c)+zero(i,t,s,c)+pos(i,t,s,c));
%                     for h = 1:numChan
                        if percentNeg(i,t,s,c) >= 0.75 % if that one epoch in 1trial/1subj/1cond is mostly NEGATIVE
                            classBTN(i,t,s,c) = -1;
                            classEEGNeg(:,i,:,t,s,c) = epochsEEG(:,i,:,t,s,c);
                            % want a list of all of the epochs that are
                            % negative, but also retain individual data
                            % points in these epochs
                            % size epochsEEG = [216 120 5 5 1 5] =
                            % [timepts, epochs, channels, trials, subj,
                            % conditions] 
                            
                        else
                            classEEGNeg(:,i,:,t,s,c) = nan(numTimept,1,numChan); 
                        end
                        if percentZero(i,t,s,c) >= 0.75
                            classBTN(i,t,s,c) = 0;
                            classEEGZero(:,i,:,t,s,c) = epochsEEG(:,i,:,t,s,c);
                        else
                            classEEGZero(:,i,:,t,s,c) = nan(numTimept,1,numChan); 
                        end
                        if percentPos(i,t,s,c) >= 0.75
                            classBTN(i,t,s,c) = 1;
                            classEEGPos(:,i,:,t,s,c) = epochsEEG(:,i,:,t,s,c);
                        else
                            classEEGPos(:,i,:,t,s,c) = nan(numTimept,1,numChan); 
                        end
%                     end
                end
            end
        end
    end
    
    % get a list of all of the epochs in each state and average them (for
    % EEG data)
    
    
        aggrData = zeros(numTimept,numChan,numStates,numCond);
    stateCount = zeros(numStates,numCond); % for each condition, how many are in each state? 
    
    
    %     for c = 1:numCond-2 % not actually necessary; just a check
%         stateCount(1,c) = size(posEpoch{c},1); % num of epochs in each state in each condition for COND 1-3
%         stateCount(2,c) = size(zeroEpoch{c},1);
%         stateCount(3,c) = size(negEpoch{c},1);
%     end
      
%     for c=1:numCond-2 % cond
%         for s = 1:numStates % states
%             subplot(3,3,3*c-2)
%             plot(posEEGAvg{c}(:,chan))
%             title(sprintf('Subplot %d: FLA, Cond %d',c,c))
%             subplot(3,3,3*c-1)
%             plot(zeroEEGAvg{c}(:,chan))
%             title(sprintf('Subplot %d: AMB, Cond %d',c+3,c)) % move to diff figure 
%             subplot(3,3,3*c)
%             plot(negEEGAvg{c}(:,chan))
%             title(sprintf('Subplot %d: AM, Cond %d',c+6,c))
%         end
%     end