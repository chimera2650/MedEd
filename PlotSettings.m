%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Load Variables
d_name = 'med_ed.mat'; % Name of master data file
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
end

clear comp

cd(master_dir);
load(d_name);

%% ERP Settings
erp.chan_name = 'FCz';
erp.c_index = find(summary.chanlocs.labels == erp.chan_name);
erp.significance = 0.05;
erp.x_lim = [-200 600];
erp.y_lim = [-20 20];

%% FFT Settings
fft.chan_name(1) = 'Fz';
fft.chan_name(2) = 'Pz';
fft.significance = 0.05;
fft.c_index(1) = find(summary.chanlocs.labels == fft.chan_name(1));
fft.c_index(2) = find(summary.chanlocs.labels == fft.chan_name(2));
fft.f_wind(1) = [5 7];
fft.f_wind(2) = [10 14];

%% WAV Settings
wav.chan_name(1) = 'Fz';
wav.chan_name(2) = 'Pz';
wav.significance = 0.05;
wav.c_index(1) = find(summary.chanlocs.labels == wav.chan_name(1));
wav.c_index(2) = find(summary.chanlocs.labels == wav.chan_name(2));
wav.f_wind(1) = [5 7];
wav.f_wind(2) = [10 14];

t_wind1 = [-1000 -500];
f_wind1 = [5 7];
t_wind2 = [-800 -500];
f_wind2 = [10 14];
wav_limits = [-2 2];
topo_limits = [-1.25 1.25];
cond1 = 1;
cond2 = 3;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Feedback NL';
    fft_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    wav_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    topo_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    beh_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition','remove');
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    erp_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback';
    erpnl_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Feedback NL';
    fft_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    wav_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    topo_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    beh_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition',[1921,45,1280,907]);
end

clear comp

%% Load Variables
cd(master_dir);
load(d_name);

for a = 1:62
    if strcmp(summary.chanlocs(a).labels,chan_name1) == 1
        chan_loc(a) = 1;
    elseif strcmp(summary.chanlocs(a).labels,chan_name2) == 1
        chan_loc(a) = 2;
    elseif strcmp(summary.chanlocs(a).labels,chan_name3) == 1
        chan_loc(a) = 3;
    else
        chan_loc(a) = 0;
    end
end

sig_label = strcat('p > ',num2str(significance));

% Theta highlight
wav_wind1 = [min(t_wind1) min(f_wind1) 2;...
    max(t_wind1) min(f_wind1) 2;...
    max(t_wind1) max(f_wind1) 2;...
    min(t_wind1) max(f_wind1) 2];

% Alpha highlight
wav_wind2 = [min(t_wind2) min(f_wind2) 2;...
    max(t_wind2) min(f_wind2) 2;...
    max(t_wind2) max(f_wind2) 2;...
    min(t_wind2) max(f_wind2) 2];

clear a;