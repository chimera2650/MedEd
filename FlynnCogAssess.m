clc;
clear;

cd('C:\Users\Jordan\Documents\MATLAB\flynn');

for a = 1:2
    if a == 1
        FLYNN('C:\Users\Jordan\Documents\MATLAB\MedEd\Config\RewPConfig.txt',...
            'Standard-10-20-NEL-62.locs');
    elseif a == 2
        FLYNN('C:\Users\Jordan\Documents\MATLAB\MedEd\Config\P300Config.txt',...
            'Standard-10-20-NEL-62.locs');
    end
end

clear a;