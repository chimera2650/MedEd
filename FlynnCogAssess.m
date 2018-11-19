clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for i = 1:2
    if i == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\RewPConfig.txt';
    elseif i == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\P300Config.txt';
    end
    
    FLYNN(analysis,'C:\Users\Jordan\Documents\MATLAB\flynn\Standard-10-20-NEL-62.locs');
end