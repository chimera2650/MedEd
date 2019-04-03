function tScore = ttestFFT(dataFile)

dispstat('','init');
dispstat(sprintf('Calculating FFT ttest scores. Please wait...'),'keepthis');
channelCount = size(dataFile,1);
frequencyCount = size(dataFile,2);
conditionCount = size(dataFile,3);
subjectCount = size(dataFile,4);

for channelCounter = 1:channelCount
    if channelCounter == 1
        progressLast = 0;
        dispstat(sprintf('Progress %d%%',0))
    end
    
    progressStat = round((channelCounter/channelCount)*100);
    
    if progressStat ~= progressLast
        dispstat(sprintf('Progress %d%%',progressStat));
    end
    
    progressLast = progressStat;
        
    for frequencyCounter = 1:frequencyCount       
        for conditionCounter = 1:conditionCount
            for subjectCounter = 1:subjectCount
                summaryData(:,conditionCounter) =...
                    squeeze(dataFile(channelCounter,frequencyCounter,conditionCounter,:));
            end
        end
        
        testData1 = squeeze(summaryData(:,1));
        testData2 = squeeze(summaryData(:,3));        
        [h,p] = ttest(testData1,testData2,'tail','both');
        ttestData(channelCounter,frequencyCounter) = p;
    end
end

dispstat('Finished.','keepprev');
tScore = ttestData;
end