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
    
    data = squeeze(mean(summary.(analysis).data(:,7:15,:,:,:),5));
    diff_data = squeeze(data(:,:,:,2) - data(:,:,:,1));
    
    for b = 1:2
        if b == 1
            c_index = find(chan_loc == 1);
        elseif b == 2
            c_index = find(chan_loc == 2);
        end
        
        chan_data(:,:) = diff_data(c_index,:,:);
        freq_data = [];
        
        for c = 1:size(chan_data,1)
            if c == 1
                freq_data = chan_data(1,:);
            else
                freq_data = cat(2,freq_data,chan_data(c,:));
            end
        end
        
        freq_data = transpose(freq_data);
        
        [idx,C] = kmeans(freq_data,clust_count,...
            'Distance','sqeuclidean',...
            'MaxIter',100);
        
        freq_data = transpose(freq_data);
        freq_clust = transpose(idx);
        t_start = 1;
        t_end = 500;
        
        for c = 1:9
            clust_data(c,:) = freq_data(1,t_start:t_end);
            clust_index(c,:) = freq_clust(1,t_start:t_end);
            t_start = t_start + 500;
            t_end = t_end + 500;
        end
        
        chan_clust(b,:,:) = clust_data(:,:);
        chan_index(b,:,:) = clust_index(:,:);
    end
    
    clusters.(analysis).index = chan_index;
    clusters.(analysis).data = chan_clust;
end


clearvars a analysis b c C c_index chan_clust chan_data chan_index clust_data clust_index data diff_data freq_clust freq_data idx t_start t_end;

%% Plot data
colors1 = cbrewer('div','RdBu',64,'PCHIP');
colors1 = flipud(colors1);
colors2 = cbrewer('qual','Set1',5);
colors2 = flipud(colors2);

%analysis = 'template';
analysis = 'decision';

if analysis == 'template'
    x_lim = [0 1996];
    x_tick = [0 500 1000 1500 2000];
    index = 2;
elseif analysis == 'decision'
    x_lim = [-1996 0];
    x_tick = [-2000 -1500 -1000 -500 0];
    index = 4;
end

[theta_row, theta_col] = find(squeeze(clusters.(analysis).index(1,:,:)) == index);

new_theta(1:9,1:500) = 0;
for counter = 1:length(theta_row)
    new_theta(theta_row(counter),theta_col(counter)) = squeeze(clusters.(analysis).data(1,theta_row(counter),theta_col(counter)));
end

figure;
s = pcolor(summary.(analysis).time,summary.(analysis).freq(1,7:15),squeeze(clusters.(analysis).data(1,:,:)));
hold on
contour(summary.(analysis).time,summary.(analysis).freq(1,7:15),new_theta(1:9,:),1,'-k','LineWidth',2);
c = colorbar;
c.TickDirection = 'out';
c.Box = 'off';
c.Label.String = 'Power (dB)';
c.Limits = [-1 1];
axpos = get(gca,'Position');
cpos = c.Position;
cpos(3) = 0.5*cpos(3);
c.Position = cpos;
drawnow;
set(gca,'position',axpos);
drawnow;
ax = gca;
ax.CLim = [-1 1];
ax.FontSize = 12;
ax.FontName = 'Arial';
ax.LineWidth = 1.5;
ax.YLabel.String = 'Frequency (Hz)';
ax.YTick = [4 5 6 7 8];
ax.YLim = [4 8];
ax.XLabel.String = 'Time (ms)';
ax.XTick = x_tick;
ax.XLim = x_lim;
ax.TickDir = 'out';
ax.FontWeight = 'bold';
ax.Box = 'off';
s.EdgeColor = 'none';
s.FaceColor = 'interp';
shade.FaceColor = 'none';
shade.EdgeColor = [0 0 0];
shade.LineWidth = 2;
view([0,0,90]);
colormap(colors1);
drawnow;
hold off

figure;
s = surf(summary.(analysis).time,summary.(analysis).freq(1,7:15),squeeze(clusters.(analysis).index(1,:,:)));
c = colorbar;
c.TickDirection = 'out';
c.Box = 'off';
c.Label.String = 'Power (dB)';
c.Limits = [0 5];
c.Ticks = [0 1 2 3 4 5];
axpos = get(gca,'Position');
cpos = c.Position;
cpos(3) = 0.5*cpos(3);
c.Position = cpos;
drawnow;
set(gca,'position',axpos);
drawnow;
ax = gca;
ax.CLim = [0 5];
ax.FontSize = 12;
ax.FontName = 'Arial';
ax.LineWidth = 1.5;
ax.YLabel.String = 'Frequency (Hz)';
ax.YTick = [4 5 6 7 8];
ax.YLim = [4 8];
ax.XLabel.String = 'Time (ms)';
ax.XTick = x_tick;
ax.XLim = x_lim;
ax.TickDir = 'out';
ax.FontWeight = 'bold';
ax.Box = 'off';
s.EdgeColor = 'none';
s.FaceColor = 'interp';
shade.FaceColor = 'none';
shade.EdgeColor = [0 0 0];
shade.LineWidth = 2;
view([0,0,90]);
colormap(colors2);
drawnow;

[theta_row, theta_col] = find(squeeze(clusters.(analysis).index(1,:,:)) == 4);

new_theta(1:9,1:500) = 0;
for counter = 1:length(theta_row)
    new_theta(theta_row(counter),theta_col(counter)) = squeeze(clusters.(analysis).data(1,theta_row(counter),theta_col(counter)));
end

figure;
pcolor((squeeze(clusters.(analysis).data(1,:,:))));shading interp;
hold on
contour((new_theta(1:9,:)),1,'k');
