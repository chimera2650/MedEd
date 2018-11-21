clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for i = 1:3
    if i == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackConfig.txt';
    elseif i == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackNLConfig.txt';
    elseif i == 3
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\DecisionConfig.txt';
    end
    
    FLYNN(analysis,'C:\Users\Jordan\Documents\MATLAB\flynn\Standard-10-20-NEL-62.locs');
end