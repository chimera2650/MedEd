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
theta = [4 6];
alpha = [8 12];
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
clc;

for a = 1:2
    if a == 1
        analysis = 'template';
        freq = summary.template.freq;
    elseif a == 2
        analysis = 'decision';
        freq = summary.decision.freq;
    end
    
    for b = 1:1
        if b == 1
            c_index = find(chan_loc == 1);
            freq_range = [find(freq == theta(1)) find(freq == theta(2))];
        elseif b == 2
            c_index = find(chan_loc == 2);
            freq_range = [find(freq == alpha(1)) find(freq == alpha(2))];
        end
        
        data = squeeze(mean(summary.(analysis).data(c_index,freq_range(1):freq_range(2),:,:,:),5));
        diff_data = transpose(squeeze(data(:,:,2) - data(:,:,1)));
        [idx,C] = kmeans(diff_data,clust_count,...
            'Distance','sqeuclidean',...
            'Start','sample',...
            'Display','final',...
            'MaxIter',1000);
        k_data(b,:) = transpose(idx);
        c_data(b,:,:) = C(:,:);
        
        clearvars C chan_data data idx;
    end
    
    ktest.(analysis).time = summary.(analysis).time;
    ktest.(analysis).freq = summary.(analysis).freq(1,freq_range(1):freq_range(2));
    ktest.(analysis).data = diff_data;
    ktest.(analysis).k_data = k_data;
    ktest.(analysis).c_data = c_data;
end

clearvars c_data c_index C chan_data cond_data idx k_data temp_k_data temp_c_data;

save(save_dir,'ktest');

%% Plot data
figure(1)

for a = 1:2
    if a == 1
        analysis = 'template';
        s = 0;
    elseif a == 2
        analysis = 'decision';
        s = 2;
    end
        
    for b = 1:1
        if b == 1
            chan_name = 'Fz';
        elseif b == 2
            chan_name = 'Pz';
        end
        
        kdata = squeeze(ktest.(analysis).k_data(b,:));
        cdata = squeeze(ktest.(analysis).c_data(b,:,:));
        plotdata = squeeze(ktest.(analysis).data(:,:));
        
        subplot(2,2,b+s)
        [silh3,h] = silhouette(plotdata,kdata,'sqeuclidean');
        h = gca;
        h.Children.EdgeColor = [.8 .8 1];
        xlabel 'Silhouette Value'
        ylabel 'Cluster'
        title(['Silhouette plot for ' analysis ' at ' chan_name]);
        silmean = mean(silh3);
        disp(silmean);
    end
end

clearvars avgdata c_index chan_name h kdata plotdata silh3;

%% Clean workspace
clearvars -except ktest;
disp('Analysis complete');