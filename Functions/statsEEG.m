function stats = statsEEG(dataFile,windowFile,channelReference,channelName)
channelCount = size(dataFile,1);
conditionCount = size(dataFile,3) - 1;
subjectCount = size(dataFile,4);
windowCount = size(windowFile,2);
frequencyReference = linspace(1,30,59);

for channelCounter = 1:channelCount
    if strcmp(channelReference(channelCounter).labels,channelName) == 1
        channelLocation(channelCounter) = 1;
    end
end

channelIndex = find(channelLocation == 1);

for windowCounter = 1:windowCount
    windowMin = find(frequencyReference == min(windowFile.(windowCounter)));
    windowMax = find(frequencyReference == max(windowFile.(windowCounter)));
    
    for subjectCounter = 1:subjectCount
        for conditionCounter = 1:conditionCount
            conditionData(:,conditionCounter) = squeeze(dataFile(channelIndex,windowMin:windowMax,conditionCounter,subjectCounter));
        end
        
        conditionData = squeeze(mean(conditionData,1));
        subjectData(subjectCounter,:) = conditionData;
        conditionData = [];
    end
    
    [h,p] = ttest(subjectData(1,:),subjectData(2,:));
    stats(:,windowCounter) = p;
end

stats = array2table(stats);
stats.Properties.VariableNames = windowFile.Properties.VariableNames;
end