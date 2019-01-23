%% Code Info
% Written by Jordan Middleton 2018
% Based on code by mikexcohen@gmail.com
clear;
clc;
close all;

%% Load Variables
file_name = 'med_ed_twav.mat';
chan_name1 = 'Fz';
chan_name2 = 'Pz';
pval = 0.05;
min_freq = 1;
max_freq = 15;
num_frex = 29;
min_time = 0;
max_time = 1996;
num_time = 500;
n_permutes = 1000;
c_lim = [-1.5 1.5];
x_lim = [min_time max_time];
y_lim = [min_freq max_freq];
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
load(file_name);
zval = abs(norminv(pval));
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

freq_points = linspace(1,15,29);
time_points = linspace(0,1996,500);
max_cluster_sizes = zeros(1,n_permutes);
max_val = zeros(n_permutes,2);
cluster_thresh = prctile(max_cluster_sizes,100 - (100 * pval));

clear a;

for y = 1:2
    %% Statistics via permutation testing
    if y == 1
        chan_name = chan_name1;
    else
        chan_name = chan_name2;
    end
    
    c_index = find(chan_loc == y);
    WAV_data = squeeze(summary.raw(c_index,1:29,:,[1,3],:));
    WAV_data1 = permute(squeeze(WAV_data(:,:,1,:)),[3,1,2]);
    WAV_data2 = permute(squeeze(WAV_data(:,:,2,:)),[3,1,2]);
    temp_dist = cat(3,WAV_data1,WAV_data2);
    perm_dist = permute(temp_dist,[2,3,1]);
    permmaps = zeros(n_permutes,num_frex,num_time);
    diff_map = mean(squeeze(WAV_data(:,:,2,:) - WAV_data(:,:,1,:)),3);
    
    for b = 1:n_permutes
        random_perm = randperm(size(perm_dist,2));
        temp_perm = perm_dist(:,random_perm,:);
        permmaps(b,:,:) = squeeze(mean((temp_perm(:,1:num_time,:) -...
            temp_perm(:,num_time+1:end,:)),3));
    end
    
    mean_h0 = squeeze(mean(permmaps,1));
    std_h0 = squeeze(std(permmaps,1));
    zmap = (diff_map - mean_h0) ./ std_h0;
    zmap(abs(zmap) < zval) = 0;
    
    %% Correct for multiple comparisons
    for c = 1:n_permutes
        threshimg = squeeze(permmaps(c,:,:));
        threshimg = (threshimg - mean_h0) ./ std_h0;
        threshimg(abs(threshimg) < zval) = 0;
        islands = bwconncomp(threshimg);
        
        if numel(islands.PixelIdxList)>0
            tempclustsizes = cellfun(@length,islands.PixelIdxList);
            max_cluster_sizes(c) = max(tempclustsizes);
        end
        
        temp = sort(reshape(permmaps(c,:,:),1,[]));
        max_val(c,:) = [min(temp) max(temp)];
    end
    
    %% Threshold based on cluster size
    zmap_clust = zmap;
    islands = bwconncomp(zmap_clust);
    
    for d = 1:islands.NumObjects
        if numel(islands.PixelIdxList{d} == d) < cluster_thresh
            zmap_clust(islands.PixelIdxList{d}) = 0;
        end
    end
    
    %% Threshold based on cluster value    
    thresh_lo = prctile(max_val(:,1),100 * (pval / 2));
    thresh_hi = prctile(max_val(:,2),100 - 100 * (pval / 2));
    zmap_tcorr = diff_map;
    zmap_tcorr(zmap_tcorr > thresh_lo & zmap_tcorr < thresh_hi) = 0;
    
    %% Plot data
    figure(1)
    if y == 1
        plot_num = 0;
    else
        plot_num = 2;
    end
    
    subplot(2,2,plot_num+1)
    hist(max_cluster_sizes,50);
    line([prctile(max_cluster_sizes,100 - (100 * pval)) ...
        prctile(max_cluster_sizes,100 - (100 * pval))],...
        [0 120],'Color',[1 0 0])
    
    subplot(2,2,plot_num + 2)
    hist(max_val,1000);
    line([thresh_lo thresh_lo],[1 40]);
    line([thresh_hi thresh_hi],[1 40]);
    
    if y == 1
        plot_num = 0;
    else
        plot_num = 3;
    end
    
    figure(2)
    subplot(2,3,plot_num + 1)
    s = surf(time_points,freq_points,diff_map);
    xlabel('Time (ms)'), ylabel('Frequency (Hz)');
    set(gca,'clim',c_lim,'xlim',x_lim,'ylim',y_lim,'ydir','nor');
    title(['Wavelet transform at ' chan_name]);
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