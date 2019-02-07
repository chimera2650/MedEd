%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
chan_name1 = 'Fz';
chan_name2 = 'Pz';
t_name = 'med_ed_twav.mat'; % Name of master data file
d_name = 'med_ed_dwav.mat'; % Name of master data file
significance = 0.05;
wav_limits = [-1 1];
cond1 = 1;
cond2 = 3;
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
    set(0,'DefaultFigurePosition',[1921,45,1280,907]);
end

clear comp

%% Load Variables
cd(master_dir);
load('chanlocs.mat');
sig_label = strcat('p > ',num2str(significance));

for b = 1:62
    if strcmp(chanlocs(b).labels,chan_name1) == 1
        chan_loc(b) = 1;
    elseif strcmp(chanlocs(b).labels,chan_name2) == 1
        chan_loc(b) = 2;
    end
end

clear a;

%% Plot Cohen's d for wavelets
disp('Plotting ttest');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);

for a = 1:2
    if a == 1
        cd(master_dir);
        load(t_name);
        analysis = 'template';
        save_name = 'TTest_Template';
        f1 = figure('Name','Template','NumberTitle','off','Position',[0,0,2400,800]);
        x_tick = [0 500 1000 1500 2000];
        x_lim = [0 2000];
        time = summary.time;
    elseif a == 2
        cd(master_dir);
        load(d_name);
        analysis = 'decision';
        save_name = 'TTest_Decision';
        f2 = figure('Name','Decision','NumberTitle','off','Position',[0,0,2400,800]);
        x_tick = [-2000 -1500 -1000 -500 0];
        x_lim = [-2000 0];
        time = summary.time;
    end
    
    for b = 1:2
        if b == 1
            d = 0;
            c_index = find(chan_loc == 1);
            chan_name = chan_name1;
            y_lim = [1 30];
            y_tick = [0 5 10 15 20 25 30];
        elseif b == 2
            c_index = find(chan_loc == 2);
            chan_name = chan_name2;
            y_lim = [1 30];
            y_tick = [0 5 10 15 20 25 30];
            d = 3;
        end
        
        for c = 1:3
            if c == 1
                sig = 0.1;
            elseif c == 2
                sig = 0.05;
            elseif c == 3
                sig = 0.01;
            end
            
            sigdata = squeeze(summary.ttest(c_index,:,:));
            plotdata = sigdata;
            freq = summary.freq;
            
            plotdata(abs(sigdata) > sig) = 0;
            plotdata(abs(sigdata) <= sig) = 1;
                        
            subplot(2,3,c+d);
            s = surf(time,freq,plotdata);
            
            title(['TTest of wavelet at ' chan_name ' during ' analysis ' at ' num2str(sig)]);
            set(gca,'ydir','normal');
            
            c = colorbar;
            c.TickDirection = 'out';
            c.Box = 'off';
            c.Label.String = 'Cohens d';
            c.Limits = wav_limits;
            drawnow;
            
            axpos = get(gca,'Position');
            cpos = c.Position;
            cpos(3) = 0.5*cpos(3);
            c.Position = cpos;
            drawnow;
            
            set(gca,'position',axpos);
            drawnow;
            
            ax = gca;
            ax.CLim = wav_limits;
            ax.FontSize = 12;
            ax.FontName = 'Arial';
            ax.LineWidth = 1.5;
            ax.YLabel.String = 'Frequency (Hz)';
            ax.YTick = y_tick;
            ax.YLim = y_lim;
            ax.XLabel.String = 'Time (ms)';
            ax.XTick = x_tick;
            ax.XLim = x_lim;
            ax.ZLabel.String = 'Cohens d';
            ax.ZTick = [-2 -1.5 -1 -0.5 0 0.5 1 1.5 2];
            ax.ZLim = [-2 2];
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
    
    if a == 1
        export_fig(f1,save_name,'-png');
    elseif a == 2
        export_fig(f2,save_name,'-png');
    end
end

%% Clean Workspace
clearvars -except summary