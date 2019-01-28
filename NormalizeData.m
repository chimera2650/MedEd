%% Code Info
% Written by Jordan Middleton 2018
% Based on code by mikexcohen@gmail.com
clear;
clc;
close all;

%% Load Variables
t_name = 'med_ed_twav.mat';
d_name = 'med_ed_dwav.mat';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_norm.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_norm.mat';
end

clearvars comp;

%% Load Data
cd(master_dir);
load('chanlocs.mat');

%% Calculate k-means
for a = 1:2    
    if a == 1
        cd(master_dir);
        load(t_name);
        analysis = 'template';
    elseif a == 2
        cd(master_dir);
        load(d_name);
        analysis = 'decision';
    end
    
    disp(['Creating normalized data for ' analysis]);
    
    for b = 1:size(summary.raw,1)        
        for c = 1:size(summary.raw,5)
            temp_cond(:,:,1) = squeeze(summary.raw(b,:,:,1,c));
            temp_cond(:,:,2) = squeeze(summary.raw(b,:,:,3,c));
            
            for d = 1:size(temp_cond,1)
                temp_data(1,:) = squeeze(temp_cond(d,:,1));
                temp_data(2,:) = squeeze(temp_cond(d,:,2));
                temp_stdev(1) = std(squeeze(temp_data(1,:)));
                temp_stdev(2) = std(squeeze(temp_data(2,:)));
                temp_mean(1) = mean(squeeze(temp_data(1,:)));
                temp_mean(2) = mean(squeeze(temp_data(2,:)));
                temp_z(d,:,1) = (temp_data(1,:) - temp_mean(1)) ./ temp_stdev(1);
                temp_z(d,:,2) = (temp_data(2,:) - temp_mean(2)) ./ temp_stdev(2);
            end
            
            sub_data(:,:,:,c) = temp_z(:,:,:);
            
            clearvars d temp_data temp_mean temp_stdev temp_z;
        end
        
        z_data(b,:,:,:,:) = sub_data(:,:,:,:);
        
        clearvars c sub_data temp_cond;
    end
    
    if a == 1
        t_data = z_data;
        t_time = summary.time;
        t_freq = summary.freq;
    elseif a == 2
        d_data = z_data;
        d_time = summary.time;
        d_freq = summary.freq;
    end
    
    clearvars b z_data;
end

clearvars a analysis summary;

summary.template.data = t_data;
summary.template.freq = t_freq;
summary.template.time = t_time;
summary.decision.data = d_data;
summary.decision.freq = d_freq;
summary.decision.time = d_time;

%% Save Data
disp('Saving data');
save(save_dir,'summary');

%% Clean workspace
clearvars -except d_data summary t_data;
disp('Analysis complete');
