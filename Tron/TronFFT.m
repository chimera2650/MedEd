%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
% Name of master data file
masterName = 'MedEdFFT.mat';
% Prefix used for files to be analyzed
filePrefix = 'MedEdFlynn_';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    stimulusDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Stimulus';
    responseDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Response';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\MedEdFFT.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    stimulusDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Stimulus';
    responseDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Response';
    saveDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\MedEdFFT.mat';
end

clearvars comp;

%% Load Data
% Temporarily add functions folder to path
addpath(genpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\'));
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
cd(masterDirectory);
load(masterName);
load('chanlocs.mat');
channelReference = chanlocs;

clearvars chanlocs masterDirectory masterName;

%% Summarize FFT data for stimulus
% Call function to create initial summary table
raw = summarizeFFT(stimulusDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsFFT(stimulusDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevFFT(raw);
% Call function to calculate confidence intervals within subjects
ci = ciFFT(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestFFT(raw);
% Call a function to generate a linear dataset to represent frequency points
frequency = frequencyPoints(1,30,0.5);

% Combine all data into summary file structure for later export
summary.stimulus.raw = raw;
summary.stimulus.artifacts = artifacts;
summary.stimulus.stdev = stdev;
summary.stimulus.ci = ci;
summary.stimulus.ttest = tScore;
summary.stimulus.frequency = frequency;

% Clear unneeded variables from workspace
clearvars artifacts ci frequencyPoints peak raw stdev stimulusDirectory tScore;

%% Summarize FFT data for response
% Call function to create initial summary table
raw = summarizeFFT(responseDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsFFT(responseDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevFFT(raw);
% Call function to calculate confidence intervals within subjects
ci = ciFFT(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestFFT(raw);
% Call a function to generate a linear dataset to represent frequency points
frequency = frequencyPoints(1,30,0.5);

% Combine all data into summary file structure for later export
summary.response.raw = raw;
summary.response.artifacts = artifacts;
summary.response.stdev = stdev;
summary.response.ci = ci;
summary.response.ttest = tScore;
summary.response.frequency = frequency;

% Clear unneeded variables from workspace
clearvars artifacts ci frequencyPoints peak raw responseDirectory stdev tScore;

%% Save dataset and clean workspace
disp('Saving data');
save(saveDirectory,'summary');
disp('Analysis complete');

clearvars -except summary;