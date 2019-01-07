clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for a = 1:3
    if a == 1
        FLYNN('C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackConfig.txt',...
            'Standard-10-20-NEL-62.locs');
    elseif a == 2
        FLYNN('C:\Users\Jordan\Documents\MATLAB\MedEd\Config\FeedbackNLConfig.txt',...
            'Standard-10-20-NEL-62.locs');
    elseif a == 3
        FLYNN('C:\Users\Jordan\Documents\MATLAB\MedEd\Config\DecisionConfig.txt',...
            'Standard-10-20-NEL-62.locs');
    end
end

clear a;