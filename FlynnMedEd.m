clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for a = 2:2
    if a == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackConfig.txt';
    elseif a == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackNLConfig.txt';
    elseif a == 3
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\DecisionConfig.txt';
    end
    
    FLYNN(analysis,'C:\Users\Jordan\Documents\MATLAB\flynn\Standard-10-20-NEL-62.locs');
end

clear a;
clear analysis;