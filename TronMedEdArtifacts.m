%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;

%% Set Variables
prefix = 'MedEdFlynn_';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_path = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\final_summary.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Feedback';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Big System\Decision';
    save_path = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\final_summary.mat';
end

clear comp

%% Load Data
cd(working_dir);
load('final_summary.mat');

%% Summarize ERP
cd(working_dir1);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for x = 1:file_num
    subject_data = importdata(filenames(x).name); % Import subject data
    artA = subject_data.ERP.nAccepted;
    artR = subject_data.ERP.nRejected;
    artW(1,1) = artA(1,1);
    artW(1,2) = artR(1,1);
    artL(1,1) = artA(1,2);
    artL(1,2) = artR(1,2);
    win(x,:) = artW;
    loss(x,:) = artL;
end

win = cell2mat(win);
loss = cell2mat(loss);
win(:,3) = (win(:,1)./(win(:,1)+win(:,2))).*100;
loss(:,3) = (loss(:,1)./(loss(:,1)+loss(:,2))).*100;
final_summary.ERP.artifacts.win = win;
final_summary.ERP.artifacts.loss = loss;

clear artA;
clear artL;
clear artR;
clear artW;
clear file_num;
clear filenames;
clear loss;
clear subject_data;
clear win;
clear x;

%% Summarize FFT
cd(working_dir2);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for x = 1:file_num
    subject_data = importdata(filenames(x).name); % Import subject data
    artA = subject_data.FFT.nAccepted;
    artR = subject_data.FFT.nRejected;
    art0c(1,1) = artA(1,1);
    art0c(1,2) = artR(1,1);
    art1c(1,1) = artA(1,2);
    art1c(1,2) = artR(1,2);
    art2c(1,1) = artA(1,3);
    art2c(1,2) = artR(1,3);
    no_conflict(x,:) = art0c;
    one_conflict(x,:) = art1c;
    two_conflict(x,:) = art2c;
end

no_conflict = cell2mat(no_conflict);
one_conflict = cell2mat(one_conflict);
two_conflict = cell2mat(two_conflict);
no_conflict(:,3) = (no_conflict(:,1)./(no_conflict(:,1)+no_conflict(:,2))).*100;
one_conflict(:,3) = (one_conflict(:,1)./(one_conflict(:,1)+one_conflict(:,2))).*100;
two_conflict(:,3) = (two_conflict(:,1)./(two_conflict(:,1)+two_conflict(:,2))).*100;
final_summary.FFT.artifacts.no_conflict = no_conflict;
final_summary.FFT.artifacts.one_conflict = one_conflict;
final_summary.FFT.artifacts.two_conflict = two_conflict;

clear art0c;
clear art1c;
clear art2c;
clear artA;
clear artR;
clear file_num;
clear filenames;
clear no_conflict;
clear one_conflict;
clear subject_data;
clear two_conflict;
clear x;

%% Summarize Wavelet
cd(working_dir2);
filenames = dir(strcat(prefix,'*'));   % Get a count of file number
file_num = length(filenames);

for x = 1:file_num
    subject_data = importdata(filenames(x).name); % Import subject data
    artA = subject_data.WAV.nAccepted;
    artR = subject_data.WAV.nRejected;
    art0c(1,1) = artA(1,1);
    art0c(1,2) = artR(1,1);
    art1c(1,1) = artA(1,2);
    art1c(1,2) = artR(1,2);
    art2c(1,1) = artA(1,3);
    art2c(1,2) = artR(1,3);
    no_conflict(x,:) = art0c;
    one_conflict(x,:) = art1c;
    two_conflict(x,:) = art2c;
end

no_conflict = cell2mat(no_conflict);
one_conflict = cell2mat(one_conflict);
two_conflict = cell2mat(two_conflict);
no_conflict(:,3) = (no_conflict(:,1)./(no_conflict(:,1)+no_conflict(:,2))).*100;
one_conflict(:,3) = (one_conflict(:,1)./(one_conflict(:,1)+one_conflict(:,2))).*100;
two_conflict(:,3) = (two_conflict(:,1)./(two_conflict(:,1)+two_conflict(:,2))).*100;
final_summary.wavelet.artifacts.no_conflict = no_conflict;
final_summary.wavelet.artifacts.one_conflict = one_conflict;
final_summary.wavelet.artifacts.two_conflict = two_conflict;

clear art0c;
clear art1c;
clear art2c;
clear artA;
clear artR;
clear file_num;
clear filenames;
clear no_conflict;
clear one_conflict;
clear subject_data;
clear two_conflict;
clear x;

%% Save Data
save('C:\Users\Jordan\Documents\MATLAB\TronMedEd\final_summary.mat','final_summary');