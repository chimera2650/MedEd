% Copyright (C) 2019 Jordan Middleton

% This function takes the outputs of all other functions and converts them
% to CSV for plotting in R. The inputs are [dataFile: the name of the data
% to be converted to CSV], [channelName: the name of the channel that you
% want the data exported for; the function can determine row name from a
% string match], [channelReference: the name of the EEGLab format chanlocs
% file used for row reference in the data], [analysis: the analysis for
% which the data is to be exported; used to determine dimensions, etc. of
% export file]

function dataExport = eegExport(dataFile,channelName,channelReference,analysis)
% This section is for ERP or FFT data. They both have the same dimensions,
% so the data is handled the same way.
if strcmp(analysis,'ERP') || strcmp(analysis,'FFT') == 1
    % Identify the number of channels
    channelCount = size(dataFile,1);
    % Identify the number of conditions
    conditionCount = size(dataFile,3);
    
    % This loop finds the row index of the desired channel for exporting
    for channelCounter = 1:channelCount
        if strcmp(channelReference(channelCounter).labels,channelName) == 1
            channelLocation(channelCounter) = 1;
        end
    end
    
    channelIndex = find(channelLocation == 1);
    % Average the two conditions across participants and generate a
    % difference wave (conflict - control) for export
    tempData = squeeze(mean(dataFile(channelIndex,:,conditionCount,:),4) -...
        mean(dataFile(channelIndex,:,1,:),4));
    
% This section handles the wavelet data. It is almost identical to the
% ERP/FFT data, except has one additional dimension
elseif strcmp(analysis,'WAV') == 1
    % Identify the number of channels
    channelCount = size(dataFile,1);
    % Identify the number of conditions
    conditionCount = size(dataFile,4);
    
    % This loop finds the row index of the desired channel for exporting
    for channelCounter = 1:channelCount
        if strcmp(channelReference(channelCounter).labels,channelName) == 1
            channelLocation(channelCounter) = 1;
        end
    end
    
    channelIndex = find(channelLocation == 1);
    % Average the two conditions across participants and generate a
    % difference wave (conflict - control) for export
    tempData = squeeze(mean(dataFile(channelIndex,:,:,conditionCount,:),4) -...
        mean(dataFile(channelIndex,:,1,:),4));
    
% The data format for PCA analysis is much simpler, so no averaging is
% required. Just simple export
elseif strcmp(analysis,'PCA') == 1
    tempData = dataFile;
    
% The behavioural data is averaged across subjects first, then descriptive
% statistics are performed of the subject means
elseif strcmp(analysis,'behavioural') == 1
    % This is effectively a condition counter
    conflictCount = max(dataFile.conflict);
    % Determine the number of subjects
    subjectCount = size(unique(dataFile.subject),1);
    
    % This loop calculated the descriptive statistics on the participant
    % means
    for conflictCounter = 1:conflictCount
        % Select only the means for each conflict condition seperately
        conditionConflict = dataFile.conflict == conflictCounter;
        tempFile = dataFile(conditionConflict,:);
        % Calculate a grand average of the subject means
        avg(conflictCounter,1) = nanmean(tempFile.mean);
        % Calculate the standard deviation of the subject means
        stdev(conflictCounter,1) = nanstd(tempFile.mean);
        % List the total number of subject
        count(conflictCounter,1) = length(tempFile.mean);
        % Calculate the standard error of the subject means
        error(conflictCounter,1) = (stdev(conflictCounter,1)./sqrt(count(conflictCounter,1)));
        tStat = tinv(0.95,(count(conflictCounter,1))-1);
        % Calculate the confidence interval of the subject means
        ci(conflictCounter,1) = avg(conflictCounter,1) + (tStat.*error(conflictCounter,1));
    end
    
    % Combine all the descriptive data into a single table
    tempData = table(avg,stdev,count,error,ci);
    % Convert the summary table into a numeric array for export
    tempData = table2array(tempData);
end

dataExport = tempData;
end