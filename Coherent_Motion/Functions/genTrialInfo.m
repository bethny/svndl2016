function trialInfo = genTrialInfo(t,dataFolder,dataFiles,respOnly,respTimes,pre,post)

    if pre > 10
        pre = pre/1000;
    end

    if post > 10
        post = post/1000;
    end

    trialInfo(1) = str2double(dataFiles{t}(strfind(dataFiles{t},'_c')+2:strfind(dataFiles{t},'_c')+4)); % condition
    trialInfo(2) = checkResp3(respOnly(t),trialInfo(1));
        dSet = load(sprintf('%s/%s',dataFolder,dataFiles{t}));
        ep = dSet.IsEpochOK;
        percentIsEpochOK = sum(sum(ep))/(size(ep,1)*size(ep,2));
    trialInfo(3) = percentIsEpochOK;
        rawData = dSet.RawTrial(:,1:size(ep,2));
    trialInfo(4) = respTimes(t);
    trialInfo(5) = respTimes(t) - pre;
    trialInfo(6) = respTimes(t) + post;
end