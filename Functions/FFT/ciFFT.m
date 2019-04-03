function ci = ciFFT(dataFile)

dispstat('','init');
dispstat(sprintf('Calculating FFT confidence intervals. Please wait...'),'keepthis');
channelCount = size(dataFile,1);
frequencyCount = size(dataFile,2);
conditionCount = size(dataFile,3);
subjectCount = size(dataFile,4);

for channelCounter = 1:channelCount
    for frequencyCounter = 1:frequencyCount       
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
                summaryData(subjectCounter,conditionCounter) = dataFile(channelCounter,frequencyCounter);
            end
        end
        
        conditionRemove = isnan(summaryData(:,2));
        summaryData(conditionRemove,:) = [];
        summaryData(:,2) = summaryData(:,3);
        summaryData(:,3) = [];
        [p,anovaTable] = anova1(summaryData,{'no conflict','high conflict'},'off');
        summaryData = mean(summaryData,2);
        ciData(frequencyCounter,1) = mean(summaryData);
        ciData(frequencyCounter,2) = std(summaryData);
        ciData(frequencyCounter,3) = length(summaryData);
        ciData(frequencyCounter,4) = ciData(frequencyCounter,2)/sqrt(ciData(frequencyCounter,3)-1);
        tStat = tinv(0.95,ciData(frequencyCounter,3)-1);
        ciData(frequencyCounter,5) = anovaTable{3,4};
        ciData(frequencyCounter,6) = sqrt(ciData(frequencyCounter,5)/ciData(frequencyCounter,3))*(tStat);
        
        clearvars p;
    end
    ciSummary(channelCounter,:) = transpose(ciData(:,6));
end

dispstat('Finished.','keepprev');
ci = ciSummary;
end