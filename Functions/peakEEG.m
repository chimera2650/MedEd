% Copyright (C) 2019 Jordan Middleton

function peak = peakEEG(dataFile)

channelCount = size(dataFile,1);
conditionCount = size(dataFile,3);
subjectCount = size(dataFile,4);

for channelCounter = 1:channelCount
    testData = squeeze(nanmean(dataFile(channelCounter,:,1,:),4)) -...
        squeeze(nanmean(dataFile(channelCounter,:,2,:),4));
    [peakValue,peakIndex] = max(testData(50:200));
    meanPeak(channelCounter,:) = peakValue;
    latencyPeak(channelCounter,:) = peakIndex;
    
    for conditionCounter = 1:conditionCount
        for subjectCounter = 1:subjectCount
            tempData = squeeze(dataFile(channelCounter,:,conditionCounter,subjectCounter));
            peakData(subjectCounter,conditionCounter) =...
                squeeze(nanmean(tempData(peakIndex-12:peakIndex+12)));
        end
    end
    
    stdevPeak(channelCounter,:,:) = [std(peakData(:,1)),std(peakData(:,2))];
    [h,peakSig] = ttest(peakData(:,1),peakData(:,2));
    ttestPeak(channelCounter,:) = peakSig;
    ciData = [(1.96*(stdevPeak(channelCounter,:)/sqrt(subjectCount))),...
        (1.96*(stdevPeak(channelCounter,:)/sqrt(subjectCount)))];
    ciPeak(channelCounter,:,:) = ciData;
end

peak.mean = meanPeak;
peak.latency = latencyPeak;
peak.stdev = stdevPeak;
peak.ttest = ttestPeak;
peak.ci = ciPeak;
end