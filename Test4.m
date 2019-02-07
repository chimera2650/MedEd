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
K = 4;

colors1 = cbrewer('div','RdBu',64,'PCHIP');
colors1 = flipud(colors1);
colors2 = cbrewer('qual','Set1',5);
colors2 = flipud(colors2);

for a = 1:1
    if a == 1
        analysis = 'template';
        freq = summary.template.freq;
        time = summary.template.time;
        x_lim = [0 1996];
        x_tick = [0 500 1000 1500 2000];
        figure('Name','Template','NumberTitle','off');
    elseif a == 2
        analysis = 'decision';
        freq = summary.decision.freq;
        time = summary.decision.time;
        x_lim = [-1996 0];
        x_tick = [-2000 -1500 -1000 -500 0];
        figure('Name','Decision','NumberTitle','off')
    end
    
    for b = 1:1
        if b == 1
            c_index = find(chan_loc == 1);
            freq_range = [find(freq == theta(1)) find(freq == theta(2))];
            y_lim = [4 6];
            y_tick = [4 5 6];
        elseif b == 2
            c_index = find(chan_loc == 2);
            freq_range = [find(freq == alpha(1)) find(freq == alpha(2))];
            y_lim = [8 12];
            y_tick = [8 9 10 11 12];
        end
        
        y_lim = [1 15];
        y_tick = [0 5 10 15];
        
        X = summary.(analysis).time;
        Y = freq(1:freq_count);
        data = squeeze(mean(summary.(analysis).data(c_index,1:freq_count,:,:,:),5));
        cond_data = squeeze(data(:,:,2) - data(:,:,1));
        Z = cond_data;
%         
%         [A,B,C] = find(Z);
%         kdata = [A B C];
        kdata = transpose(Z);
        
        [H,C] = kmeans(kdata,K,...
            'Distance','sqeuclidean',...
            'Start','sample');
        
%         G = reshape(H,[29 500]);
%         G = transpose(reshape(G,[500 29]));
%         C = transpose(C);
%         Z = transpose(Z);
        
        for frex = 1:K
            new_theta = Z;
            new_theta(G ~= frex) = 0;
        
            subplot(2,3,frex)
            hold on
            s = pcolor(X,Y,Z);
            t = contour(X,Y,new_theta,1,'-k','LineWidth',2);
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
            ax.YTick = y_tick;
            ax.YLim = y_lim;
            ax.XLabel.String = 'Time (ms)';
            ax.XTick = x_tick;
            ax.XLim = x_lim;
            ax.TickDir = 'out';
            ax.FontWeight = 'bold';
            ax.Box = 'off';
            s.EdgeColor = 'none';
            s.FaceColor = 'interp';
            view([0,0,90]);
            colormap(colors1);
            drawnow;
            hold off
            
%             clearvars theta_row theta_col new_theta s t ax c;
        end
        
        %         PlotClusters(Z,G,C);
        %
        %         clr = lines(K);
        %         figure;
        %         hold on
        %         plot3(Z(G == 1)
        %         g = scatter3(Z(:,1),Z(:,2),Z(:,3),36,clr(G,:),'Marker','.');
        %         c = scatter3(C(:,1),C(:,2),C(:,3),100, clr,'Marker','o','LineWidth',3);
        %         hold off
        %         xlabel('Time (ms)'),ylabel('Frequency (Hz)'),zlabel('Power (dB)')
    end
end

%% Clear
clearvars a b C c_data chan_data clr data G K kdata plotdata X X1 Y Y1 Z Z1;