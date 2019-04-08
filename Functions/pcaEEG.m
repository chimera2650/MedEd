% Copyright (C) 2019 Jordan Middleton

function pcaOutput = pcaEEG(dataFile,timeData,frequencyData,channelName,channelReference,analysis)
channelCount = size(dataFile,1);
frequencyCount = size(dataFile,2);
timeCount = size(dataFile,3);
conditionCount = size(dataFile,4) - 1;
subjectCount = size(dataFile,5);

for channelCounter = 1:channelCount
    if strcmp(channelReference(channelCounter).labels,channelName) == 1
        channelLocation(channelCounter) = 1;
    end
end

channelIndex = find(channelLocation == 1);
pcaData = squeeze(dataFile(channelIndex,:,:,[1,3],:));
time = timeData;
frequency = frequencyData;
pcaCounter = 1;

if strcmp(analysis,'temporal') == 1
    for subjectCounter = 1:subjectCount
        for conditionCounter = 1:conditionCount
            for timeCounter = 1:timeCount
                pcaTable(pcaCounter,1:frequencyCount) = pcaData(:,timeCounter,conditionCounter,subjectCounter);
                pcaCounter = pcaCounter + 1;
            end
        end
    end
    
    [PCAResults] = temporalPCA(pcaTable,time,'VMAX',5);
    
elseif strcmp(analysis,'frequency') == 1
    for subjectCounter = 1:subjectCount
        for conditionCounter = 1:conditionCount
            for frequencyCounter = 1:frequencyCount
                pcaTable(pcaCounter,1:timeCount) = pcaData(frequencyCounter,:,conditionCounter,subjectCounter);
                pcaCounter = pcaCounter + 1;
            end
        end
    end
    
    [PCAResults] = temporalPCA(pcaTable,frequency,'VMAX',5);
end

pcaOutput.plotData = PCAResults.FacPat;
pcaOutput.varianceData = PCAResults.facVar * 100;
pcaOutput.time = time;
pcaOutput.frequency = frequency;
end