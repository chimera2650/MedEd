%% Code Info
% Written by Jordan Middleton 2018
% Based on code by mikexcohen@gmail.com
clear;
clc;
close all;

%% Load Variables
analysis = 'decision';
file_name = 'med_ed_wav.mat';
chan_name1 = 'Fz';
chan_name2 = 'Pz';
pval = 0.05;
min_freq = 1;
max_freq = 15;
num_frex = 29;
min_time = -1996;
max_time = 0;
num_time = 500;
n_permutes = 1000;
c_lim = [-1.5 1.5];
x_lim = [-1996 0];
y_lim = [1 15];
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_wav.m';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_wav.m';
end

clear comp

%% Load Data
cd(master_dir);
load(file_name);
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);
chan_loc = zeros(1,62);

for a = 1:62
    if strcmp(summary.chanlocs(a).labels,chan_name1) == 1
        chan_loc(a) = 1;
    elseif strcmp(summary.chanlocs(a).labels,chan_name2) == 1
        chan_loc(a) = 2;
    end
end

freq_points = summary.(analysis).freq;
time_points = summary.(analysis).time;
max_val = zeros(n_permutes,2);
cluster_thresh = prctile(max_cluster_sizes,100 - (100 * pval));

clear a;

for a = 1:2
    if a == 1
        chan_name = chan_name1;
        plot_num = 0;
    else
        chan_name = chan_name2;
        plot_num = 3;
    end
    
    c_index = find(chan_loc == a);
    plot_data = summary.(analysis).data(c_index,:,:);
    zmap_clust = summary.(analysis).cluster(c_index,:,:);
    zmap_tcorr = summary.(analysis).maximum(c_index,:,:);
    
    figure(1)
    subplot(2,3,plot_num + 1)
    s = surf(time_points,freq_points,plot_data);
    xlabel('Time (ms)'), ylabel('Frequency (Hz)');
    set(gca,'clim',c_lim,'xlim',x_lim,'ylim',y_lim,'ydir','nor');
    title(['Wavelet transform at ' chan_name ' for ' analysis]);
    colormap(colors);
    view([0,0,90]);
    s.EdgeColor = 'none';
    s.FaceColor = 'interp';
    
    subplot(2,3,plot_num+2)
    imagesc(time_points,freq_points,zmap_clust);
    xlabel('Time (ms)'), ylabel('Frequency (Hz)');
    set(gca,'clim',[-zval zval],'xlim',x_lim,'ydir','no');
    title('Significance based on cluster size');
    colormap(colors);
    
    subplot(2,3,plot_num+3)
    imagesc(time_points,freq_points,zmap_tcorr);
    xlabel('Time (ms)'), ylabel('Frequency (Hz)');
    set(gca,'clim',[-zval zval],'xlim',x_lim,'ydir','no');
    title('Significance based on cluster max');
    colormap(colors);
end

%% Save Data

%% Clear Workspace
clearvars -except summary;