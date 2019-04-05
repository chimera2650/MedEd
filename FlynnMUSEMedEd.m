clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for a = 1:3
    if a == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\MUSEThetaConfig.txt';
    elseif a == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\MUSEAlphaConfig.txt';
    elseif a == 3
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\MUSEFeedbackConfig.txt';
    end
    
    FLYNN(analysis,'C:\Users\Jordan\Documents\MATLAB\flynn\Standard-10-20-NEL-62.locs');
end

clear a;
clear analysis;