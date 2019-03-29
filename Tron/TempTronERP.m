%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
% Name of master data file
masterName = 'med_ed_erp.mat';
% Prefix used for files to be analyzed
filePrefix = 'MedEdFlynn_';

% This section uses the computer name to determine where file names are
% located
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    erpDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback';
    erpnlDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback NL';
    saveDirectory = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_erp.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    erpDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback';
    erpnlDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback NL';
    saveDirectory = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_erp.mat';
end

clearvars comp;

%% Load Data
addpath('C:\Users\chime\Documents\MATLAB\MedEd\Functions\');
cd(masterDirectory);
load(masterName);
load('chanlocs.mat');
channelReference = chanlocs;

clearvars chanlocs;

%% Summarize ERP data
% Call function to create initial summary table
raw = combineSubjectsERP(erpDirectory,channelReference,filePrefix);

