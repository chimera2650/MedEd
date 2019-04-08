% Copyright (C) 2019 Jordan Middleton
clc;
clear;

addpath(genpath('C:\Users\Jordan\Documents\MATLAB\flynn'));
cd('C:\Users\Jordan\Documents\MATLAB\MedEd\Config');

for analysisCounter = 4:4
    if analysisCounter == 1
        analysis = 'FeedbackConfig.txt';
    elseif analysisCounter == 2
        analysis = 'FeedbackNLConfig.txt';
    elseif analysisCounter == 3
        analysis = 'TemplateConfig.txt';
    elseif analysisCounter == 4
        analysis = 'DecisionConfig.txt';
    end
    
    FLYNN(analysis,'Standard-10-20-NEL-62.locs');
end