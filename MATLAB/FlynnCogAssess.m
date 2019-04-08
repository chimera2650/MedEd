% Copyright (C) 2019 Jordan Middleton
clc;
clear;

addpath(genpath('C:\Users\Jordan\Documents\Github\flynn'));
cd('C:\Users\Jordan\Documents\Github\MedEd\MATLAB\MedEd\Config');

for analysisCounter = 1:2
    if analysisCounter == 1
        analysis = 'RewPConfig.txt';
    elseif analysisCounter == 2
        analysis = 'P300Config.txt';
    end
    
    FLYNN(analysis,'Standard-10-20-NEL-62.locs');
end