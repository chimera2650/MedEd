%% Code Info
% Written by Jordan Middleton 2018
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
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess';
    doorsDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess\Doors';
    oddballDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess\Oddball';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess\CogAssess.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess';
    doorsDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess\Doors';
    oddballDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Oddball';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\Cog Assess\CogAssess.mat';
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
raw = summarizeERP(doorsDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsERP(doorsDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevERP(raw);
% Call function to calculate confidence intervals within subjects
ci = ciERP(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestERP(raw);
% Call function to calculate peak value, latency, and significance
peak = peakERP(raw);
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
raw = summarizeERP(oddballDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsERP(oddballDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevERP(raw);
% Call function to calculate confidence intervals within subjects
ci = ciERP(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestERP(raw);
% Call function to calculate peak value, latency, and significance
peak = peakERP(raw);
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