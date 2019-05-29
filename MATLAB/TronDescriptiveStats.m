%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data files
masterName = 'MedEdFFT.mat';
% Define frequency band windows
delta = [1;3.5];
theta = [4;7.5];
alpha = [8;12.5];
beta = [13;30];
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
disp('Loading data');
cd(masterDirectory);
load(masterName);
load('chanlocs.mat');
channelReference = chanlocs;
windows = table(delta,theta,alpha,beta);

clear alpha beta chanlocs delta masterDirectory masterName theta;

%% ANOVA Analysis
disp('Running multiple comparisons ANOVA');
anovaData = anovaEEG(summary.stimulus.raw,summary.response.raw,windows,...
     channelReference,channelFrontal,channelParietal);
anovaData = table2array(anovaData);
% measurements = table([1,1,1,1,2,2,2,2]',[1,2,3,4,1,2,3,4]','VariableNames',{'w1','w2'});
% anovaModel = fitrm(anovaData,'condition*(time + band) ~ subject*value','WithinDesign',measurements);
% anovaResults = ranova(anovaModel);

%% Statistics Analysis
disp('Running post hoc testing');
[stimulusFz,statData(1,1,:,:,:)] = statsEEG(summary.stimulus.raw,windows,channelReference,channelFrontal);
[stimulusPz,statData(1,2,:,:,:)] = statsEEG(summary.stimulus.raw,windows,channelReference,channelParietal);
[responseFz,statData(2,1,:,:,:)] = statsEEG(summary.response.raw,windows,channelReference,channelFrontal);
[responsePz,statData(2,2,:,:,:)] = statsEEG(summary.response.raw,windows,channelReference,channelParietal);
statTable = vertcat(stimulusFz,stimulusPz,responseFz,responsePz);
statTable.Row = {'Fz Stimulus';'Pz Stimulus';'Fz Response';'Pz Response'};

clearvars channelFrontal channelParietal channelReference responseFz...
    responsePz stimulusFz stimulusPz summary windows;

%% Consolidate Data
disp('Consolidating and saving data')
stats.table = statTable;
stats.anova = anovaData;
save(saveDirectory,'stats');
csvwrite('C:\Users\chime\Documents\Github\Data\MedEd\R\FFT Data\anova.csv',anovaData);

clearvars -except stats;

disp('Analysis complete');