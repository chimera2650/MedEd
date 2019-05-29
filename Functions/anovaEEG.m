function anovaData = anovaEEG(dataFile1,dataFile2,windowFile,channelReference,channelName1,channelName2)
dataFile1(:,:,2,:) = [];
dataFile2(:,:,2,:) = [];
channelCount = size(dataFile1,1);
conditionCount = size(dataFile1,3);
subjectCount = size(dataFile1,4);
windowCount = size(windowFile,2);
frequencyReference = linspace(1,30,59);

for channelCounter = 1:channelCount
    if strcmp(channelReference(channelCounter).labels,channelName1) == 1
        channelLocation(channelCounter) = 1;
    elseif strcmp(channelReference(channelCounter).labels,channelName2) == 1
        channelLocation(channelCounter) = 2;
    end
end

indexFront = find(channelLocation == 1);
indexPost = find(channelLocation == 2);

for windowCounter = 1:windowCount
    windowMin = find(frequencyReference == min(windowFile.(windowCounter)));
    windowMax = find(frequencyReference == max(windowFile.(windowCounter)));
    dataMean1(:,:,:,windowCounter) = squeeze(mean(dataFile1(:,windowMin:windowMax,:,:),2));
    dataMean2(:,:,:,windowCounter) = squeeze(mean(dataFile2(:,windowMin:windowMax,:,:),2));
    
    clearvars dataTable1 dataTable2 windowMax windowMin;
end

dataTable(:,:,:,:,1) = dataMean1([indexFront indexPost],:,:,:);
dataTable(:,:,:,:,2) = dataMean2([indexFront indexPost],:,:,:);
dataTable = permute(dataTable,[1 5 2 4 3]);

for channelCounter = 1:2
    channelFactor = ones(30,1) .* channelCounter;
    
    for timeCounter = 1:2
        timeFactor = ones(30,1) .* timeCounter;
        
        for conditionCounter = 1:2
            conditionFactor = ones(30,1) .* conditionCounter;
            
            for bandCounter = 1:4
                bandFactor = ones(30,1) .* bandCounter;
                subjectFactor = linspace(1,30,30)';
                bandData = squeeze(dataTable(channelCounter,timeCounter,conditionCounter,bandCounter,:));
                tempTable = horzcat(channelFactor,timeFactor,conditionFactor,...
                    bandFactor,subjectFactor,bandData);
                
                if bandCounter == 1
                    bandTable = tempTable;
                else
                    bandTable = [bandTable;tempTable];
                end
                
                clearvars bandData bandFactor subjectFactor tempTable;
            end
            
            if conditionCounter == 1
                conditionTable = bandTable;
            else
                conditionTable = [conditionTable;bandTable];
            end
            
            clearvars bandTable conditionData conditionFactor;
        end
        
        if timeCounter == 1
            timeTable = conditionTable;
        else
            timeTable = [timeTable;conditionTable];
        end
        
        clearvars conditionTable timeData timeFactor;
    end
    
    if channelCounter == 1
        channelTable = timeTable;
    else
        channelTable = [channelTable;timeTable];
    end
    
    clearvars channelData channelFactor timeTable;
end

anovaData = array2table(channelTable);
anovaData.Properties.VariableNames = {'time','channel','condition','band','subject','value'};
end