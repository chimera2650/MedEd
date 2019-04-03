%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
% Name of master data file
masterName = 'MedEdERP.mat';
% Prefix used for files to be analyzed
filePrefix = 'MedEdFlynn_';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    learnerDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Learners';
    nonlearnerDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Nonlearners';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\MedEdERP.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    learnerDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Learners';
    nonlearnerDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Nonlearners';
    saveDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\MedEdERP.mat';
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

%% Summarize ERP data (learners)
% Call function to create initial summary table
raw = summarizeERP(learnerDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsERP(learnerDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevERP(raw);
% Call function to calculate confidence intervals within subjects
ci = ciERP(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestERP(raw);
% Call function to calculate peak value, latency, and significance
peak = peakERP(raw);
% Call a function to generate a linear dataset to represent time points
time = timePoints(-200,600,4);

% Combine all data into summary file structure for later export
summary.erp.raw = raw;
summary.erp.artifacts = artifacts;
summary.erp.stdev = stdev;
summary.erp.ci = ci;
summary.erp.ttest = tScore;
summary.erp.peak = peak;
summary.erp.time = time;

% Clear unneeded variables from workspace
clearvars artifacts ci learnerDirectory peak raw stdev timePoints tScore;

%% Summarize ERP data (non-learners)
% Call function to create initial summary table
raw = summarizeERP(nonlearnerDirectory,channelReference,filePrefix);
% Call function to compile total artifact counts by subject
artifacts = artifactsERP(nonlearnerDirectory,channelReference,filePrefix);
% Call function to calculate standard deviations between subjects
stdev = stdevERP(raw);
% Call function to calculate confidence intervals within subjects
ci = ciERP(raw);
% Call function to calculate ttest scores between subjects
tScore = ttestERP(raw);
% Call function to calculate peak value, latency, and significance
peak = peakERP(raw);
% Call a function to generate a linear dataset to represent time points
time = timePoints(-200,600,4);

% Combine all data into summary file structure for later export
summary.erpnl.raw = raw;
summary.erpnl.artifacts = artifacts;
summary.erpnl.stdev = stdev;
summary.erpnl.ci = ci;
summary.erpnl.ttest = tScore;
summary.erpnl.peak = peak;
summary.erpnl.time = time;

% Clear unneeded variables from workspace
clearvars artifacts ci nonlearnerDirectory peak raw stdev timePoints tScore;

%% Save dataset and clean workspace
disp('Saving data');
save(saveDirectory,'summary');
disp('Analysis complete');

clearvars -except summary;