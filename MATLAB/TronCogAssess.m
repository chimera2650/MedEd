%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data file
masterName = 'CogAssess.mat';
% Prefix used for files to be analyzed
filePrefix = 'CogAssess_flynn_';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\Github\Data\Cog Assess';
    doorsDirectory = 'C:\Users\chime\Documents\Github\Data\Cog Assess\Doors';
    oddballDirectory = 'C:\Users\chime\Documents\Github\Data\Cog Assess\Oddball';
    saveDirectory = 'C:\Users\chime\Documents\Github\Data\Cog Assess\CogAssess.mat';
    addpath(genpath('C:\Users\chime\Documents\Github\MedEd\Functions'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\Github\Data\Cog Assess';
    doorsDirectory = 'C:\Users\Jordan\Documents\Github\Data\Cog Assess\Doors';
    oddballDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\Oddball';
    saveDirectory = 'C:\Users\Jordan\Documents\Github\Data\Cog Assess\CogAssess.mat';
    addpath(genpath('C:\Users\Jordan\Documents\Github\MedEd\Functions'));
end

clearvars comp;

%% Load Data
% Temporarily add functions folder to path
addpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\');
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
cd(masterDirectory);
%load(masterName);
load('chanlocs.mat');
channelReference = chanlocs;

clearvars chanlocs masterDirectory masterName;

%% Summarize data for Doors task
% Call function to create initial summary table
raw = summarizeEEG(doorsDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsEEG(doorsDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevEEG(raw);
% Call function to calculate confidence intervals within subjects
ci = ciEEG(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestEEG(raw);
% Call function to calculate peak value, latency, and significance
peak = peakEEG(raw);
% Call a function to generate a linear dataset to represent time points
timePoints = timepointsERP(-200,600,4);

% Combine all data into summary file structure for later export
cogAssess.doors.raw = raw;
cogAssess.doors.artifacts = artifacts;
cogAssess.doors.stdev = stdev;
cogAssess.doors.ci = ci;
cogAssess.doors.ttest = tScore;
cogAssess.doors.peak = peak;
cogAssess.doors.time = timePoints;

% Clear unneeded variables from workspace
clearvars artifacts ci learnerDirectory peak raw stdev timePoints tScore;

%% Summarize data for Oddball task
% Call function to create initial summary table
raw = summarizeEEG(oddballDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsEEG(oddballDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevEEG(raw);
% Call function to calculate confidence intervals within subjects
ci = ciEEG(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestEEG(raw);
% Call function to calculate peak value, latency, and significance
peak = peakEEG(raw);
% Call a function to generate a linear dataset to represent time points
timePoints = timepointsERP(-200,600,4);

% Combine all data into summary file structure for later export
cogAssess.oddball.raw = raw;
cogAssess.oddball.artifacts = artifacts;
cogAssess.oddball.stdev = stdev;
cogAssess.oddball.ci = ci;
cogAssess.oddball.ttest = tScore;
cogAssess.oddball.peak = peak;
cogAssess.oddball.time = timePoints;

% Clear unneeded variables from workspace
clearvars artifacts ci nonlearnerDirectory peak raw stdev timePoints tScore;

%% Save dataset and clean workspace
disp('Saving data');
save(saveDirectory,'cogAssess');
disp('Analysis complete');

clearvars -except cogAssess;