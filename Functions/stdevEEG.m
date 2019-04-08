% Copyright (C) 2019 Jordan Middleton

function stdev = stdevEEG(dataFile,analysis)

% Standard Deviation
disp(['Calculating ' analysis ' standard deviations']);
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