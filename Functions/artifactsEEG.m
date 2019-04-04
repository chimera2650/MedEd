% This function takes a directory of Flynn output files and extracts the
% artifact rejection counts for each condition into a single array.

function artifacts = artifactsEEG(directory,channelFile,prefix,analysis)

% Change directory to desired location
cd(directory);
% Import standardized channel locations file
channelReference = channelFile;
% Define list of file names based on provided prefix
fileName = dir(strcat(prefix,'*'));
% Define file count
fileNumber = length(fileName);
disp(['Summarizing ' analysis ' artifacts by subject']);

for fileCounter = 1:fileNumber
    % First, data is collected by subject into a temporary array
    subjectData = importdata(fileName(fileCounter).name);
    % Pull artifact data from individual subject files and compile
    artifactData(fileCounter,1) = squeeze(mean(cell2mat(subjectData.(analysis).nAccepted)));
    artifactData(fileCounter,2) = squeeze(mean(cell2mat(subjectData.(analysis).nRejected)));
end

artifacts = artifactData;
end