%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;
close all;

%% Load Variables
d_name = 'med_ed_norm.mat';
clust_count = 10;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_ktest.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_ktest.mat';
end

clearvars comp

%% Load Data
disp('Loading data');
cd(master_dir);
load(d_name);
load('chanlocs.mat');

for a = 1:2
    if a == 1
        analysis = 'template';
    elseif a == 2
        analysis = 'decision';
    end
    
    dispstat('','init');
    dispstat(sprintf(['Calculating k-clusters for ' analysis]),'keepthis');
    data = squeeze(mean(summary.(analysis).data,5));
    
    for b = 1:size(data,4)
        cond_data(:,:,:) = data(:,:,:,b);
        
        for c = 1:size(cond_data,1)
            if b == 1
                t_index = round(((c / size(cond_data,1)) * 50));
            elseif b == 2
                t_index = round(50 + ((c / size(cond_data,1)) * 50));
            end
            
            dispstat(sprintf('Progress %d%%',t_index));
            chan_data(:,:) = cond_data(c,:,:);
            [idx,C] = kmeans(chan_data,clust_count);
            temp_k_data(c,:) = transpose(idx);
            temp_c_data(c,:,:) = C(:,:);
        end
        
        k_data(:,:,b) = temp_k_data;
        c_data(:,:,:,b) = temp_c_data;
    end
    
    dispstat('Finished.','keepprev');
    ktest.(analysis).time = summary.(analysis).time;
    ktest.(analysis).freq = summary.(analysis).freq;
    ktest.(analysis).data = summary.(analysis).data;
    ktest.(analysis).k_data = k_data;
    ktest.(analysis).c_data = c_data;
end

%% Save data
disp('Saving data');
save(save_dir,'ktest');

%% Clean workspace
clearvars -except ktest;
disp('Analysis complete');