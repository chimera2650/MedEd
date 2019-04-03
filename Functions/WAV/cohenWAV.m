% This function takes a 5D array with dimensions
% [channel,frequency,time,condition,subject] and calculates the Cohen's D
% effect size between contitions and subject for each data point. The
% output is a 3D array with dimensions [channel,frequency,time].

function cohenData = cohenWAV(dataFile)
% Define number of channels in dataset
channelCount = size(dataFile,1);
% Define number of frequencies in dataset
frequencyCount = size(dataFile,2);
% Define number of time points in dataset
timeCount = size(dataFile,3);
% Define number of subjects in dataset
subjectCount = size(dataFile,5);
dispstat('','init');
dispstat(sprintf(['Calculating Cohens d between no conflict and high conflict conditions. Please wait...']),'keepthis');

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
    
    % These nested loops calculate effect size at each frequency and time
    % point
    for frequencyCounter = 1:frequencyCount
        for timeCounter = 1:timeCount
            % Isolate the two conditions to be compared at each datapoint
            tempData(1,:) = squeeze(dataFile(channelCounter,frequencyCounter,timeCounter,1,:));
            tempData(2,:) = squeeze(dataFile(channelCounter,frequencyCounter,timeCounter,3,:));
            % Calculate the standard deviations for both conditions
            stdevData(1) = std(tempData(1,:));
            stdevData(2) = std(tempData(2,:));
            % Calculate the means for both conditions
            meanData(1) = mean(tempData(1,:));
            meanData(2) = mean(tempData(2,:));
            % Calculate the pooled standard deviation
            stdevPool = sqrt(((stdevData(1)^2) + (stdevData(2)^2)) / (subjectCount - 2));
            % Calculate the Cohen's D score and store in a 3D array
            cohenData(channelCounter,frequencyCounter,timeCounter) = (meanData(2) - meanData(1)) / stdevPool;
        end
    end
end

dispstat('Finished','keepprev');
% Define output array
cohen = cohenData;
end