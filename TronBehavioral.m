%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
% Name of master data file
masterName = 'MedEdBehavioural.mat';
% Prefix used for files to be analyzed
filePrefix = 'Medical_DM_';
% Numbers for files to be included
fileKeep = '001,002,003,005,008,009,011,012,013,014,022,024,025,027,029,030,031,035,037,041,043,044,047,048,049,051,054,056,057';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    behaviouralDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral';
    rawDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral\Raw\';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\MedEdBehavioural.mat';
    addpath(genpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    behaviouralDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral';
    rawDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral\Raw\';
    saveDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\MedEdBehavioural.mat';
    addpath(genpath('C:\Users\Jordan\Documents\MATLAB\MedEd\Functions\'));
end

clearvars comp;

%% Analyze feedback data
addpath(genpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\'));
cd(masterDirectory);
%load(masterName);
% Call a function to load summary file for conflict condition
subjectData = loadBehavioural(behaviouralDirectory,'MedEdFeedback.txt');
% Call function to correct conflict scores due to programming oversight
subjectData = correctBehavioural(subjectData);

% Generate a table to report ttest results
ttestData = table('Size',[1 3],'VariableTypes',{'double','double','double'},...
    'VariableNames',{'accuracy','reactionTime','confidence'});

% Call function to generate a table of summarized correlation scores
correlation = correlateBehavioural(subjectData);

% Call function to generate a summary tables by both subject and conflict
accuracy.summary = summarizeBehavioural(subjectData,'winloss');
reactionTime.summary = summarizeBehavioural(subjectData,'RT');
confidence.summary = summarizeBehavioural(subjectData,'confidence');

% Call function to calculate within subject confidence intervals
accuracy.ci = ciBehavioural(accuracy.summary);
reactionTime.ci = ciBehavioural(reactionTime.summary);
confidence.ci = ciBehavioural(confidence.summary);

% Call function to run a two-tailed ttest to determine significance between
% conditions
ttestData.accuracy = ttestBehavioural(accuracy.summary);
ttestData.reactionTime = ttestBehavioural(reactionTime.summary);
ttestData.confidence = ttestBehavioural(confidence.summary);

% Combine all data into one structure for saving
feedback.accuracy = accuracy;
feedback.reactionTime = reactionTime;
feedback.confidence = confidence;
feedback.correlation = correlation;
feedback.ttestData = ttestData;

clearvars accuracy confidence correlation reactionTime ttestData;

%% Analyze conflict data
addpath(genpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\'));
cd(masterDirectory);
%load(masterName);
% Call a function to load summary file for conflict condition
subjectData = loadBehavioural(behaviouralDirectory,'MedEdConflict.txt');
% Call function to correct conflict scores due to programming oversight
subjectData = correctBehavioural(subjectData);

% Generate a table to report ttest results
ttestData = table('Size',[1 3],'VariableTypes',{'double','double','double'},...
    'VariableNames',{'accuracy','reactionTime','confidence'});

% Call function to generate a table of summarized correlation scores
correlation = correlateBehavioural(subjectData);

% Call function to generate a summary tables by both subject and conflict
accuracy.summary = summarizeBehavioural(subjectData,'winloss');
reactionTime.summary = summarizeBehavioural(subjectData,'RT');
confidence.summary = summarizeBehavioural(subjectData,'confidence');

% Call function to calculate within subject confidence intervals
accuracy.ci = ciBehavioural(accuracy.summary);
reactionTime.ci = ciBehavioural(reactionTime.summary);
confidence.ci = ciBehavioural(confidence.summary);

% Call function to run a two-tailed ttest to determine significance between
% conditions
ttestData.accuracy = ttestBehavioural(accuracy.summary);
ttestData.reactionTime = ttestBehavioural(reactionTime.summary);
ttestData.confidence = ttestBehavioural(confidence.summary);

% Combine all data into one structure for saving
conflict.accuracy = accuracy;
conflict.reactionTime = reactionTime;
conflict.confidence = confidence;
conflict.correlation = correlation;
conflict.ttestData = ttestData;

clearvars accuracy confidence correlation reactionTime ttestData;

%% Consolidate important values identified by participants
values = importantValues(rawDirectory,filePrefix,fileKeep);

% Combine all data into one final structure
behavioural.feedback = feedback;
behavioural.conflict = conflict;
behavioural.values = values;

clearvars conflict feedback values;

%% Save data
save(saveDirectory,'behavioural');

clearvars -except behavioural;