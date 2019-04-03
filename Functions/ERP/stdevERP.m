function stdev = stdevERP(dataFile)

% Standard Deviation for ERP
disp('Calculating ERP standard deviations');
channelCount = size(dataFile,1);
conditionCount = size(dataFile,3);
subjectCount = size(dataFile,4);

for channelCounter = 1:channelCount
   for conditionCounter = 1:conditionCount
      for subjectCounter = 1:subjectCount
          channelData(subjectCounter,:) = squeeze(dataFile(channelCounter,:,conditionCounter,subjectCounter));
      end
      
      stdevData(channelCounter,:,conditionCounter) = nanstd(channelData,1);
   end
end

stdev = stdevData;
end