%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;
close all;

%% Load Variables
d_name = 'med_ed_norm.mat';
chan_name1 = 'Fz';
chan_name2 = 'Pz';
clust_count = 5;
freq_count = 29;
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
cd(master_dir);
load(d_name);
load('chanlocs.mat');

chan_loc = zeros(1,62);

for a = 1:62
    if strcmp(chanlocs(a).labels,chan_name1) == 1
        chan_loc(a) = 1;
    elseif strcmp(chanlocs(a).labels,chan_name2) == 1
        chan_loc(a) = 2;
    end
end

%% Create Clusters
clust_count = 5;

for a = 1:2
    if a == 1
        analysis = 'template';
    elseif a == 2
        analysis = 'decision';
    end
    
    data = squeeze(mean(summary.(analysis).data(:,1:freq_count,:,:,:),5));
    diff_data = squeeze(data(:,:,:,2) - data(:,:,:,1));
    
    for b = 1:2
        if b == 1
            c_index = find(chan_loc == 1);
        elseif b == 2
            c_index = find(chan_loc == 2);
        end
        
        chan_data(:,:) = diff_data(c_index,:,:);
        
        for c = 1:size(chan_data,1)
            freq_data = transpose(chan_data(c,:));
            
            [idx,C] = kmeans(freq_data,clust_count,...
                'Distance','sqeuclidean',...
                'MaxIter',100);
            
            freq_clust(c,:) = transpose(idx);
        end
        
        chan_clust(b,:,:) = freq_clust(:,:);
    end
    
    clusters.(analysis) = chan_clust;
end


clearvars a analysis b c C c_index chan_clust chan_data data freq_clust freq_data idx;



%% Plot data
colors = cbrewer('qual','Dark2',clust_count);
