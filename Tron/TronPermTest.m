%% Code Info
% Written by Jordan Middleton 2018
% Based on code by mikexcohen@gmail.com
clear;
clc;
close all;

%% Load Variables
t_name = 'med_ed_twav.mat';
d_name = 'med_ed_dwav.mat';
pval = 0.05;
n_permutes = 1000;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    tsave_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_tperm.mat';
    dsave_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed_dperm.mat';
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    tsave_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_tperm.mat';
    dsave_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed_dperm.mat';
end

clearvars comp

%% Load Data
zval = abs(norminv(pval));

for a = 1:2
    if a == 1
        cd(master_dir);
        analysis = 'template';
        load(t_name);
        save_dir = tsave_dir;
        time_point = linspace(0,1996,500);
    elseif a == 2
        cd(master_dir);
        analysis = 'decision';
        load(d_name);
        save_dir = dsave_dir;
        time_point = linspace(-1996,0,500);
    end
   
    freq_point = linspace(1,15,29);
    
    for b = 1:62
        %% Statistics via permutation testing
        WAV_data = squeeze(summary.raw(b,1:29,:,[1,3],:));
        WAV_data1 = permute(squeeze(WAV_data(:,:,1,:)),[3,1,2]);
        WAV_data2 = permute(squeeze(WAV_data(:,:,2,:)),[3,1,2]);
        temp_dist = cat(3,WAV_data1,WAV_data2);
        perm_dist = permute(temp_dist,[2,3,1]);
        permmaps = zeros(n_permutes,size(freq_point,2),size(time_point,2));
        diff_map = mean(squeeze(WAV_data(:,:,2,:) - WAV_data(:,:,1,:)),3);
        dispstat('','init');
        dispstat(sprintf(['Permuting ' summary.chanlocs(b).labels ' wavelets for '...
            analysis '. Please wait...']),'keepthis');
        
        for c = 1:n_permutes
            perc_stat = round((c / n_permutes) * 100);
            dispstat(sprintf('Progress %d%%',perc_stat));
            random_perm = randperm(size(perm_dist,2));
            temp_perm = perm_dist(:,random_perm,:);
            permmaps(c,:,:) = squeeze(mean((temp_perm(:,1:size(time_point,2),:) -...
                temp_perm(:,size(time_point,2)+1:end,:)),3));
        end
        
        clearvars c perm_dist perc_stat random_perm temp_dist temp_perm WAV_data ...
            WAV_data1 WAV_data2 
        
        mean_h0 = squeeze(mean(permmaps,1));
        std_h0 = squeeze(std(permmaps,1));
        zmap = (diff_map - mean_h0) ./ std_h0;
        zmap(abs(zmap) < zval) = 0;
        
        %% Correct for multiple comparisons      
        max_cluster_sizes = zeros(1,n_permutes);
        max_val = zeros(n_permutes,2);
        cluster_thresh = prctile(max_cluster_sizes,100 - (100 * pval));
        
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
        
        clearvars c max_cluster_sizes mean_h0 permmaps std_h0 temp ...
            tempclustsizes threshimg;
        
        %% Threshold based on cluster size
        dispstat('Finished.','keepprev');
        zmap_clust = zmap;
        islands = bwconncomp(zmap_clust);
        
        for c = 1:islands.NumObjects
            if numel(islands.PixelIdxList{c} == c) < cluster_thresh
                zmap_clust(islands.PixelIdxList{c}) = 0;
            end
        end
        
        clearvars c cluster_thresh islands zmap;
        
        %% Threshold based on cluster value
        thresh_lo = prctile(max_val(:,1),100 * (pval / 2));
        thresh_hi = prctile(max_val(:,2),100 - 100 * (pval / 2));
        zmap_tcorr = diff_map;
        zmap_tcorr(zmap_tcorr > thresh_lo & zmap_tcorr < thresh_hi) = 0;
        cluster(b,:,:) = zmap_clust(:,:);
        maximum(b,:,:) = zmap_tcorr(:,:);
        data(b,:,:) = diff_map(:,:);
        
        clearvars max_val thresh_hi thresh_lo zmap_clust zmap_tcorr;
    end
    
    %% Save Data
    clearvars b;
    
    disp('Saving data');
    perm.data = data;
    perm.cluster = cluster;
    perm.maximum = maximum;
    perm.freq = freq_point;
    perm.time = time_point;
    save(save_dir,'perm');
    
    clearvars analysis cluster data diff_map maximum save_dir;
end

%% Final Cleanup
disp('Analysis complete');

clearvars -except perm;