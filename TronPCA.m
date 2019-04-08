%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data file
stimulusName = 'MedEdStimulusWAV.mat';
responseName = 'MedEdResponseWAV.mat';
% Name of the channel to be analyzed
channelName = 'Fz';
% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\MedEdPCA.mat';
    addpath(genpath('C:\Users\chime\Documents\MATLAB\MATLAB-EEG-PCA-Toolbox'));
    addpath(genpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    saveDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\MedEdPCA.mat';
    addpath(genpath('C:\Users\Jordan\Documents\MATLAB\MATLAB-EEG-PCA-Toolbox'));
    addpath(genpath('C:\Users\Jordan\Documents\MATLAB\MedEd\Functions\'));
end

clearvars comp;

%% Load Data
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
cd(masterDirectory);
load('chanlocs.mat');
channelReference = chanlocs;

clearvars chanlocs;

%% Run PCA for stimulus condition
cd(masterDirectory);
load(stimulusName);

% Run the PCA in the time domain
temporal = pcaEEG(summary.raw,summary.time,summary.frequency,channelName,channelReference,'temporal');
% Run the PCA in the frequency domain
frequency = pcaEEG(summary.raw,summary.time,summary.frequency,channelName,channelReference,'frequency');

% Consolidate data
stimulus.temporal = temporal;
stimulus.frequency = frequency;

clearvars frequency stimulusName temporal;

%% Run PCA for response condition
cd(masterDirectory);
load(responseName);

% Run the PCA in the time domain
temporal = pcaEEG(summary.raw,summary.time,summary.frequency,channelName,channelReference,'temporal');
% Run the PCA in the frequency domain
frequency = pcaEEG(summary.raw,summary.time,summary.frequency,channelName,channelReference,'frequency');

% Consolidate data
response.temporal = temporal;
response.frequency = frequency;

clearvars frequency responseName temporal;

%% Consolidate data and save
PCA.stimulus = stimulus;
PCA.response = response;
save(saveDirectory,'PCA');

clearvars -except PCA;