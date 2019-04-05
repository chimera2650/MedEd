function dataExport = eegExport(dataFile,channelName,channelReference,analysis)


if strcmp(analysis,'ERP') || strcmp(analysis,'FFT') == 1
    channelCount = size(dataFile,1);
    conditionCount = size(dataFile,3);
    
    for channelCounter = 1:channelCount
        if strcmp(channelReference(channelCounter).labels,channelName) == 1
            channelLocation(channelCounter) = 1;
        end
    end
    
    channelIndex = find(channelLocation == 1);
    tempData = squeeze(mean(dataFile(channelIndex,:,conditionCount,:),4) -...
        mean(dataFile(channelIndex,:,1,:),4));
elseif strcmp(analysis,'WAV') == 1
    channelCount = size(dataFile,1);
    conditionCount = size(dataFile,4);
    
    for channelCounter = 1:channelCount
        if strcmp(channelReference(channelCounter).labels,channelName) == 1
            channelLocation(channelCounter) = 1;
        end
    end
    
    channelIndex = find(channelLocation == 1);
    tempData = squeeze(mean(dataFile(channelIndex,:,:,conditionCount,:),4) -...
        mean(dataFile(channelIndex,:,1,:),4));
elseif strcmp(analysis,'PCA') == 1
    tempData = dataFile;
elseif strcmp(analysis,'behavioural') == 1
    conflictCount = max(dataFile.conflict);
    subjectCount = size(unique(dataFile.subject),1);
    
   for conflictCounter = 1:conflictCount
       conditionConflict = dataFile.conflict == conflictCounter;
       tempFile = dataFile(conditionConflict,:);
       avg(conflictCounter,1) = nanmean(tempFile.mean);
       stdev(conflictCounter,1) = nanstd(tempFile.mean);
       count(conflictCounter,1) = length(tempFile.mean);
       error(conflictCounter,1) = (stdev(conflictCounter,1)./sqrt(count(conflictCounter,1)));
       tStat = tinv(0.95,(count(conflictCounter,1))-1);
       ci(conflictCounter,1) = avg(conflictCounter,1) + (tStat.*error(conflictCounter,1));
   end
   
   tempData = table(avg,stdev,count,error,ci);
   tempData = table2array(tempData);
end

dataExport = tempData;
end