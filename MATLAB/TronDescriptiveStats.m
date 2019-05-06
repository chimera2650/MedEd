%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data files
masterName = 'MedEdFFT.mat';
% Define frequency band windows
delta = [1 3.5];
theta = [4 7.5];
alpha = [8 12.5];
beta = [13 30];
% Define channels of interest
channelFrontal = 'Fz';
channelParietal = 'Pz';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd';
    saveDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\MedEdStats.mat';
    addpath(genpath('C:\Users\chime\Documents\Github\MedEd\Functions'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd';
    saveDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\MedEdStats.mat';
    addpath(genpath('C:\Users\Jordan\Documents\Github\MedEd\Functions'));
end

clearvars comp

%% Load Data
% Temporarily add functions folder to path
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
cd(masterDirectory);
load('chanlocs.mat');
channelReference = chanlocs;
windows = table(delta,theta,alpha,beta);

clear alpha beta chanlocs delta theta;

%% Statistics Analysis
load(masterName);
stimulusFz = statsEEG(summary.stimulus.raw,windows,channelReference,channelFrontal);
stimulusPz = statsEEG(summary.stimulus.raw,windows,channelReference,channelParietal);
responseFz = statsEEG(summary.response.raw,windows,channelReference,channelFrontal);
responsePz = statsEEG(summary.response.raw,windows,channelReference,channelParietal);
stats = vertcat(stimulusFz,stimulusPz,responseFz,responsePz);
stats.Row = {'Fz Stimulus';'Pz Stimulus';'Fz Response';'Pz Response'};

%% Save Data
disp('Saving data');
save(saveDirectory,'stats');
%% Final Cleanup
disp('Analysis complete');

clearvars -except stats;