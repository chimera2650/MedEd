clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for i = 1:2
    if i == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackConfig.txt';
    elseif i == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\DecisionConfig.txt';
    end
    
    FLYNN(analysis);
end