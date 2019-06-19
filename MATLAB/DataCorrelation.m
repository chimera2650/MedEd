%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data file
behaviouralName = 'MedEdBehavioural.mat';
erpName = 'MedEdERP.mat';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd';
    saveDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\MedEdTest.mat';
    addpath(genpath('C:\Users\chime\Documents\Github\MedEd\Functions'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd';
    saveDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\MedEdTest.mat';
    addpath(genpath('C:\Users\chime\Documents\Github\MedEd\Functions'));
end

clearvars comp;

%% Load Variables
cd(masterDirectory);
load(behaviouralName);
load(erpName);

clearvars behaviouralName erpName;

%% Compare RewP score to accuracy
