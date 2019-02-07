%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
chan_name1 = 'Fz';
chan_name2 = 'Pz';
t_name = 'med_ed_tnorm.mat';
d_name = 'med_ed_dnorm.mat';
s_name = 'WAV_Cond_Norm_';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    wav_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition','remove');
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    wav_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Export';
end

clear comp

%% Load Variables
cd(master_dir);
load('chanlocs.mat');

for c = 1:62
    if strcmp(chanlocs(c).labels,chan_name1) == 1
        chan_loc(c) = 1;
    elseif strcmp(chanlocs(c).labels,chan_name2) == 1
        chan_loc(c) = 2;
    end
end

clear a;

%% Plot Wavelets
disp('Plotting wavelets');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);

for a = 1:2
    if a == 1
        cd(master_dir);
        analysis = 'template';
        x_lim = [0 1996];
        x_tick = [0 500 1000 1500 2000];
        load(t_name);
        f1 = figure('Name','Template','NumberTitle','off','Position',[0,0,2400,800]);
        save_name = [s_name 'Template'];
    elseif a == 2
        cd(master_dir);
        analysis = 'decision';
        x_lim = [-1996 0];
        x_tick = [-2000 -1500 -1000 -500 0];
        load(d_name);
        f1 = figure('Name','Decision','NumberTitle','off','Position',[0,0,2400,800]);
        save_name = [s_name 'Decision'];
    end
    
    for b = 1:2
        if b == 1
            e = 0;
            c_index = find(chan_loc == 1);
            chan_name = chan_name1;
        elseif b == 2
            e = 3;
            c_index = find(chan_loc == 2);
            chan_name = chan_name2;
        end
        
        plotdata1 = squeeze(mean(summary.data(c_index,:,:,1),5));
        plotdata2 = squeeze(mean(summary.data(c_index,:,:,3),5));
        diffdata = plotdata2 - plotdata1;
        time = summary.time;
        freq = summary.freq;
                
        for c = 1:3
            if c == 1
                data = diffdata;
                t_lab = ['Difference wavelet for ' chan_name];
                wav_limits = [-1 1];
            elseif c == 2
                data = plotdata1;
                t_lab = ['Wavelet for ' chan_name ' during no conflict'];
                wav_limits = [-1 1];
            elseif c == 3
                data = plotdata2;
                t_lab = ['Wavelet for ' chan_name ' during high conflict'];
                wav_limits = [-1 1];
            end
            
            for d = 1:size(data,1)
                temp_data = squeeze(mean(data,1));
            end
            
            temp_mean = squeeze(mean(temp_data));
            
            data = data - temp_mean;
            
            subplot(2,3,c+e);
            s = surf(time,freq,data);
            
            title(t_lab);
            set(gca,'ydir','normal');
            
            d = colorbar;
            d.TickDirection = 'out';
            d.Box = 'off';
            d.Label.String = 'Power (dB)';
            d.Limits = wav_limits;
            drawnow;
            
            axpos = get(gca,'Position');
            cpos = d.Position;
            cpos(3) = 0.5*cpos(3);
            d.Position = cpos;
            drawnow;
            
            set(gca,'position',axpos);
            drawnow;
            
            ax = gca;
            ax.CLim = wav_limits;
            ax.FontSize = 12;
            ax.FontName = 'Arial';
            ax.LineWidth = 1.5;
            ax.YLabel.String = 'Frequency (Hz)';
            ax.YTick = [0 5 10 15 20 25 30];
            ax.YLim = [1 30];
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
            colormap(colors);
        end
    end
    
    cd(save_dir);
    export_fig(f1,save_name,'-png');
end

%% Clean Workspace
clearvars -except summary;