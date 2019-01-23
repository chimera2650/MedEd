%% Code Info
% Written by Jordan Middleton 2018
% Based on code by mikexcohen@gmail.com
clear;
clc;
close all;

%% Load Variables
t_name = 'med_ed_tperm.mat';
d_name = 'med_ed_dperm.mat';
chan_name1 = 'Fz';
chan_name2 = 'Pz';
c_lim = [-1.5 1.5];
zval = 0.05;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
end

clear comp

%% Load Data
cd(master_dir);
load('chanlocs.mat');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);
chan_loc = zeros(1,62);

for a = 1:62
    if strcmp(chanlocs(a).labels,chan_name1) == 1
        chan_loc(a) = 1;
    elseif strcmp(chanlocs(a).labels,chan_name2) == 1
        chan_loc(a) = 2;
    end
end

clearvars a chanlocs;

%% Generate Plots
for a = 1:2
    if a == 1
        load('med_ed_tperm.mat');
        analysis = 'template';
        save_name = 'Perm_Template';
        f1 = figure('Name','Template','NumberTitle','off','Position',[0,0,2400,800]);
        x_lim = [0 2000];
        x_tick = [0 500 1000 1500 2000];
    elseif a == 2
        cd(master_dir);
        load('med_ed_dperm.mat');
        analysis = 'decision';
        save_name = 'Perm_Decision';
        f2 = figure('Name','Decision','NumberTitle','off','Position',[0,0,2400,800]);
        x_lim = [-2000 0];
    end
    
    for b = 1:2
        if b == 1
            chan_name = chan_name1;
            plot_num = 0;
            freq_points = linspace(4,6,5);
            y_lim = [4 8];
            y_index = [7 11];
        else
            chan_name = chan_name2;
            plot_num = 3;
            y_lim = [8 13];
            y_index = [15 25];
        end
        
        c_index = find(chan_loc == b);
        plot_data(:,:) = squeeze(perm.data(c_index,:,:));
        zmap_clust(:,:) = squeeze(perm.cluster(c_index,:,:));
        zmap_tcorr(:,:) = squeeze(perm.maximum(c_index,:,:));
        
        subplot(2,3,plot_num + 1)
        s = surf(perm.time,perm.freq,plot_data);
        xlabel('Time (ms)'), ylabel('Frequency (Hz)');
        set(gca,'clim',c_lim,'xlim',x_lim,'ylim',y_lim,'ydir','nor');
        title(['Wavelet transform at ' chan_name ' for ' analysis]);
        colormap(colors);
        view([0,0,90]);
        s.EdgeColor = 'none';
        s.FaceColor = 'interp';
        
        subplot(2,3,plot_num + 2)
        imagesc(perm.time,perm.freq,zmap_clust);
        xlabel('Time (ms)'), ylabel('Frequency (Hz)');
        set(gca,'clim',[-zval zval],'xlim',x_lim,'ylim',y_lim,'ydir','nor');
        title('Significance based on cluster size');
        colormap(colors);
        
        subplot(2,3,plot_num + 3)
        imagesc(perm.time,perm.freq,zmap_tcorr);
        xlabel('Time (ms)'), ylabel('Frequency (Hz)');
        set(gca,'clim',[-zval zval],'xlim',x_lim,'ylim',y_lim,'ydir','nor');
        title('Significance based on cluster max');
        colormap(colors);
        
        clearvars plot_data zmap_clust zmap_tcorr;
    end
    
    %% Save Data
    cd(save_dir);
    
    if a == 1
        export_fig(f1,save_name,'-png');
    elseif a == 2
        export_fig(f2,save_name,'-png');
    end
end

%% Clear Workspace
clearvars -except perm;