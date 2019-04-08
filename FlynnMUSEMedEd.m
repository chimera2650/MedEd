% Copyright (C) 2019 Jordan Middleton
clc;
clear;

addpath(genpath('C:\Users\Jordan\Documents\MATLAB\flynn'));
cd('C:\Users\Jordan\Documents\MATLAB\MedEd\Config');

for analysisCounter = 1:3
    if analysisCounter == 1
        analysis = 'MUSEThetaConfig.txt';
    elseif analysisCounter == 2
        analysis = 'MUSEAlphaConfig.txt';
    elseif analysisCounter == 3
        analysis = 'MUSEFeedbackConfig.txt';
    end
    
    FLYNN(analysis,'Standard-10-20-NEL-62.locs');
end

clear a;
clear analysis;