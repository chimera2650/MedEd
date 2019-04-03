% This function takes a directory of Flynn output files and combines them
% into a single array with dimensions [channels,time,condition,subject].
% Inputs are [directory = path to file directory as a string], [channelFile
% = sructure containing channel names and locations in EEGLab format], and
% [prefix = string of file name prefix to identify files to acquire data
% from].

function artifacts = artifactsFFT(directory,channelFile,prefix)

% Change directory to desired location
cd(directory);
% Import standardized channel locations file
channelReference = channelFile;
% Define list of file names based on provided prefix
fileName = dir(strcat(prefix,'*'));
% Define file count
fileCount = length(fileName);
dispstat('','init');
dispstat(sprintf('Summarizing FFT artifacts by subject. Please wait...'),'keepthis');

for fileCounter = 1:fileCount
    if fileCounter == 1
        progressLast = 0;
        dispstat(sprintf('Progress %d%%',0))
    end
    
    progressStat = round((fileCounter/fileCount)*100);
    
    if progressStat ~= progressLast
        dispstat(sprintf('Progress %d%%',progressStat));
    end
    
    progressLast = progressStat;
    
    % First, data is collected by subject into a temporary array
    subjectData = importdata(fileName(fileCounter).name);
    % Pull arifact data from individual subject files and compile
    artifactData(fileCounter,1) = squeeze(mean(cell2mat(subjectData.FFT.nAccepted)));
    artifactData(fileCounter,2) = squeeze(mean(cell2mat(subjectData.FFT.nRejected)));
end

dispstat('Finished.','keepprev');
artifacts = artifactData;
end