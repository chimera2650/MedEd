% This function takes a directory of Flynn output files and combines them
% into a single array with dimensions [channels,time,condition,subject].
% Inputs are [directory = path to file directory as a string], [channelFile
% = sructure containing channel names and locations in EEGLab format], and
% [prefix = string of file name prefix to identify files to acquire data
% from].

function raw = summarizeERP(directory,channelFile,prefix)

% Change directory to desired location
cd(directory);
% Import standardized channel locations file
channelReference = channelFile;
% Define list of file names based on provided prefix
fileName = dir(strcat(prefix,'*'));
% Define file count
fileNumber = length(fileName);
% Define the number of channels to be analyzed
channelCount = length(channelReference);
disp('Summarizing ERP by subject');

for fileCounter = 1:fileNumber
    % First, data is collected by subject into a temporary array
    subjectData = importdata(fileName(fileCounter).name);
    % Determine the number of conditions that need to be summarized
    conditionCount = size(subjectData.ERP.conditions,2);
    
    for conditionCounter = 1:conditionCount
        % Each array is divided into cells, one per condition
        for channelCounter = 1:channelCount
            % Each row in the cell corrosponds to a channel
            for standardCounter = 1:channelCount
                % This normalizes the row number to ensure that all
                % channels corrospond to the same row
                if strcmpi(subjectData.chanlocs(standardCounter).labels,...
                        channelReference(channelCounter).labels) == 1
                    channelLocation(standardCounter) = 1;
                else
                    channelLocation(standardCounter) = 0;
                end
            end
            
            % Move the subject channel that matches the appropriate row in
            % the reference file to standardize row order
            channelIndex = find(channelLocation == 1);
            tempData(channelCounter,:,conditionCounter,fileCounter) =...
                subjectData.ERP.data{conditionCounter}(channelIndex,:);
        end
    end
end

raw = tempData;
end