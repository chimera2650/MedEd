% Copyright (C) 2019 Jordan Middleton

function ci = ciEEG(dataFile,analysis)

dispstat('','init');
dispstat(sprintf(['Calculating ' analysis ' confidence intervals. Please wait...']),'keepthis');
channelCount = size(dataFile,1);
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
            for subjectCounter = 1:subjectCount
                summaryData(subjectCounter,conditionCounter) = dataFile(channelCounter,timeCounter);
            end
        end
        
        conditionRemove = isnan(summaryData(:,2));
        summaryData(conditionRemove,:) = [];
        [p,tbl] = anova1(summaryData,{'win','loss'},'off');
        summaryData = mean(summaryData,2);
        ciData(timeCounter,1) = mean(summaryData);
        ciData(timeCounter,2) = std(summaryData);
        ciData(timeCounter,3) = length(summaryData);
        ciData(timeCounter,4) = ciData(timeCounter,2)/sqrt(ciData(timeCounter,3)-1);
        ts = tinv(0.95,ciData(timeCounter,3)-1);
        ciData(timeCounter,5) = tbl{3,4};
        ciData(timeCounter,6) = sqrt(ciData(timeCounter,5)/ciData(timeCounter,3))*(ts);
        
        clearvars p;
    end
    ciSummary(channelCounter,:) = transpose(ciData(:,6));
end

dispstat('Finished.','keepprev');
ci = ciSummary;
end