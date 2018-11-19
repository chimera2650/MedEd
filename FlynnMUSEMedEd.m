clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for i = 1:3
    if i == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\MUSEThetaConfig.txt';
    elseif i == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\MUSEAlphaConfig.txt';
    elseif i == 3
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\MUSEFeedbackConfig.txt';
    end
    
    FLYNN(analysis);
end