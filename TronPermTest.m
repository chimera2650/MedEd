%% Code Info
% Written by Jordan Middleton 2018
% Based on code by mikexcohen@gmail.com
clear;
clc;
close all;

%% Load Variables
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
zval = abs(norminv(pval));
freq_points = linspace(min_freq,max_freq,num_frex);
time_points = linspace(min_time,max_time,num_time);
max_cluster_sizes = zeros(1,n_permutes);
max_val = zeros(n_permutes,2);
cluster_thresh = prctile(max_cluster_sizes,100 - (100 * pval));

for a = 2:2
    if a == 1
        analysis = 'template';
    elseif a == 2
        analysis = 'decision';
    end
    
    for b = 1:62
        %% Statistics via permutation testing
        WAV_data = squeeze(summary.(analysis).raw(b,1:29,:,[1,3],:));
        WAV_data1 = permute(squeeze(WAV_data(:,:,1,:)),[3,1,2]);
        WAV_data2 = permute(squeeze(WAV_data(:,:,2,:)),[3,1,2]);
        temp_dist = cat(3,WAV_data1,WAV_data2);
        perm_dist = permute(temp_dist,[2,3,1]);
        permmaps = zeros(n_permutes,num_frex,num_time);
        diff_map = mean(squeeze(WAV_data(:,:,2,:) - WAV_data(:,:,1,:)),3);
        dispstat('','init');
        dispstat(sprintf(['Permuting ' summary.chanlocs(b).labels ' wavelets for ' analysis '. Please wait...']),'keepthis');
        
        for c = 1:n_permutes
            perc_stat = round((c / n_permutes) * 100);
            dispstat(sprintf('Progress %d%%',perc_stat));
            random_perm = randperm(size(perm_dist,2));
            temp_perm = perm_dist(:,random_perm,:);
            permmaps(c,:,:) = squeeze(mean((temp_perm(:,1:num_time,:) -...
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
        dispstat('Finished.','keepprev');
        zmap_clust = zmap;
        islands = bwconncomp(zmap_clust);
        
        for c = 1:islands.NumObjects
            if numel(islands.PixelIdxList{c} == c) < cluster_thresh
                zmap_clust(islands.PixelIdxList{c}) = 0;
            end
        end
        
        %% Threshold based on cluster value
        thresh_lo = prctile(max_val(:,1),100 * (pval / 2));
        thresh_hi = prctile(max_val(:,2),100 - 100 * (pval / 2));
        zmap_tcorr = diff_map;
        zmap_tcorr(zmap_tcorr > thresh_lo & zmap_tcorr < thresh_hi) = 0;
        summary.(analysis).cluster(b,:,:) = zmap_clust(:,:);
        summary.(analysis).maximum(b,:,:) = zmap_tcorr(:,:);
    end
end

%% Save Data
disp('Saving data');
save(save_dir,'summary');

%% Final Cleanup
disp('Analysis complete');

clearvars -except summary;