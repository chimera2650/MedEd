% This function takes a directory of Flynn output files and combines them
% into a single array with dimensions [channels,time,condition,subject].
% Inputs are [directory = path to file directory as a string], [channelFile
% = sructure containing channel names and locations in EEGLab format], and
% [prefix = string of file name prefix to identify files to acquire data
% from].

function artifacts = artifactsERP(directory,channelFile,prefix)

% Change directory to desired location
cd(directory);
% Import standardized channel locations file
channelReference = channelFile;
% Define list of file names based on provided prefix
fileName = dir(strcat(prefix,'*'));
% Define file count
fileNumber = length(fileName);
disp('Summarizing ERP artifacts by subject');

for fileCounter = 1:fileNumber
    % First, data is collected by subject into a temporary array
    subjectData = importdata(fileName(fileCounter).name);
    % Pull arifact data from individual subject files and compile
    artifactData(fileCounter,1) = squeeze(mean(cell2mat(subjectData.ERP.nAccepted)));
    artifactData(fileCounter,2) = squeeze(mean(cell2mat(subjectData.ERP.nRejected)));
end

artifacts = artifactData;
end