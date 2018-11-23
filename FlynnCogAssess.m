clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for a = 1:2
    if a == 1
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\RewPConfig.txt';
    elseif a == 2
        analysis = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Config\P300Config.txt';
    end
    
    FLYNN(analysis,'C:\Users\Jordan\Documents\MATLAB\flynn\Standard-10-20-NEL-62.locs');
end

clear a;
clear analysis;