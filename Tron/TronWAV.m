%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
% Name of master data file
stimulusName = 'MedEdStimulusWAV.mat';
responseName = 'MedEdResponseWAV.mat';
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
    saveStimulusDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\MedEdStimulusWAV.mat';
    saveResponseDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\MedEdResponseWAV.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    stimulusDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Stimulus';
    responseDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Response';
    saveStimulusDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\MedEdStimulusWAV.mat';
    saveResponseDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\MedEdResponseWAV.mat';
end

clearvars comp;

%% Load Data
% Temporarily add functions folder to path
addpath(genpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\'));
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
cd(masterDirectory);
load('chanlocs.mat');
channelReference = chanlocs;

clearvars chanlocs;

%% Summarize WAV data for stimulus
cd(masterDirectory);
load(stimulusName);
% Call function to create initial summary table
raw = summarizeWAV(stimulusDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsWAV(stimulusDirectory,channelReference,filePrefix);
% Call function to calculate Cohen's D effect size between subjects
cohen = cohenWAV(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestWAV(raw);
% Call a function to generate a linear dataset to represent frequency points
frequency = frequencyPoints(1,30,0.5);
% Call a function to generate a linear dataset to represent time points
time = timePoints(0,2000,4);

% Combine all data into summary file structure for later export
summary.raw = raw;
summary.artifacts = artifacts;
summary.cohen = cohen;
summary.ttest = tScore;
summary.frequency = frequency;
summary.time = time;

disp('Saving data');
save(saveStimulusDirectory,'summary');

% Clear unneeded variables from workspace
clearvars artifacts ci cohen frequency raw saveStimulusDirectory stimulusDirectory stimulusName summary time tScore;

%% Summarize WAV data for response
cd(masterDirectory);
load(responseName);
% Call function to create initial summary table
raw = summarizeWAV(responseDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsWAV(responseDirectory,channelReference,filePrefix);
% Call function to calculate Cohen's D effect size between subjects
cohen = cohenWAV(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestWAV(raw);
% Call a function to generate a linear dataset to represent frequency points
frequency = frequencyPoints(1,30,0.5);
% Call a function to generate a linear dataset to represent time points
time = timePoints(-2000,0,4);

% Combine all data into summary file structure for later export
summary.raw = raw;
summary.artifacts = artifacts;
summary.cohen = cohen;
summary.ttest = tScore;
summary.frequency = frequency;
summary.time = time;

disp('Saving data');
save(saveResponseDirectory,'summary');

% Clear unneeded variables from workspace
clearvars artifacts ci cohen frequency raw responseDirectory responseName saveResponseDirectory summary time tScore;