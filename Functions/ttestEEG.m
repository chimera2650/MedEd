% Copyright (C) 2019 Jordan Middleton

function tScore = ttestEEG(dataFile,analysis)
dispstat('','init');
dispstat(sprintf(['Calculating ' analysis ' ttest scores. Please wait...']),'keepthis');
channelCount = size(dataFile,1);

if strcmp(analysis,'WAV') == 0
    timeCount = size(dataFile,2);
    conditionCount = size(dataFile,3);
    subjectCount = size(dataFile,4);
    
    for channelCounter = 1:channelCount
        for timeCounter = 1:timeCount
            if channelCounter == 1
                progressLast = 0;
                dispstat(sprintf('Progress %d%%',0))
            end
            
            progressStat = round((channelCounter/channelCount)*100);
            
            if progressStat ~= progressLast
                dispstat(sprintf('Progress %d%%',progressStat));
            end
            
            progressLast = progressStat;
            
            for conditionCounter = 1:conditionCount
                summaryData(:,conditionCounter) = dataFile(channelCounter,timeCounter,conditionCounter,:);
            end
            
            tempData1 = summaryData(:,1);
            tempData2 = summaryData(:,2);
            [h,p] = ttest(tempData1,tempData2,'tail','both');
            ttestData(channelCounter,timeCounter) = p;
        end
    end
else
    frequencyCount = size(dataFile,2);
    timeCount = size(dataFile,3);
    conditionCount = size(dataFile,4);
    subjectCount = size(dataFile,5);
    
    for channelCounter = 1:channelCount
        for frequencyCounter = 1:frequencyCount
            for timeCounter = 1:timeCount
                if channelCounter == 1
                    progressLast = 0;
                    dispstat(sprintf('Progress %d%%',0))
                end
                
                progressStat = round((channelCounter/channelCount)*100);
                
                if progressStat ~= progressLast
                    dispstat(sprintf('Progress %d%%',progressStat));
                end
                
                progressLast = progressStat;
                
                for conditionCounter = 1:conditionCount
                    summaryData(:,conditionCounter) = dataFile(channelCounter,frequencyCounter,timeCounter,conditionCounter,:);
                end
                
                tempData1 = summaryData(:,1);
                tempData2 = summaryData(:,conditionCount);
                [h,p] = ttest(tempData1,tempData2,'tail','both');
                ttestData(channelCounter,frequencyCounter,timeCounter) = p;
            end
        end
    end
end

dispstat('Finished.','keepprev');
tScore = ttestData;
end