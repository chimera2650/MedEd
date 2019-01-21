%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
chan_name1 = 'Fz';
chan_name2 = 'Pz';
d_name = 'med_ed_wav.mat'; % Name of master data file
significance = 0.05;
wav_limits = [-2 2];
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
load(d_name);
sig_label = strcat('p > ',num2str(significance));

for b = 1:62
    if strcmp(summary.chanlocs(b).labels,chan_name1) == 1
        chan_loc(b) = 1;
    elseif strcmp(summary.chanlocs(b).labels,chan_name2) == 1
        chan_loc(b) = 2;
    end
end

clear a;

%% Plot Cohen's d for wavelets
disp('Plotting Cohens d');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);

for a = 2:2
    for b = 1:2
        if a == 1
            analysis = 'template';
            save_name = 'Cohen_Template';
            f1 = figure('Name','Cohens d','NumberTitle','off');
        elseif a == 2
            analysis = 'decision';
            save_name = 'Cohen_Decision';
            f2 = figure('Name','Cohens d','NumberTitle','off');
        end
        
        if b == 1
            c_index = find(chan_loc == 2);
            chan_name = chan_name1;
            y_lim = [4 6];
            y_tick = [4 5 6];
            plotdata = squeeze(summary.(analysis).cohen(c_index,7:11,1:499));
            freq = summary.(analysis).freq(1,7:11);
        elseif b == 2
            c_index = find(chan_loc == 3);
            chan_name = chan_name2;
            y_lim = [8 12];
            y_tick = [8 9 10 11 12];
            plotdata = squeeze(summary.(analysis).cohen(c_index,15:23,1:499));
            freq = summary.(analysis).freq(1,15:23);
        end
        
        time = summary.(analysis).time;
        
        subplot(2,1,b);
        s = surf(time,freq,plotdata);
        
        title(['Cohens d of wavelet at ' chan_name ' during ' analysis]);
        set(gca,'ydir','normal');
        
        c = colorbar;
        c.TickDirection = 'out';
        c.Box = 'off';
        c.Label.String = 'Cohens d';
        c.Limits = [-2 2];
        drawnow;
        
        axpos = get(gca,'Position');
        cpos = c.Position;
        cpos(3) = 0.5*cpos(3);
        c.Position = cpos;
        drawnow;
        
        set(gca,'position',axpos);
        drawnow;
        
        ax = gca;
        ax.CLim = [-2 2];
        ax.FontSize = 12;
        ax.FontName = 'Arial';
        ax.LineWidth = 1.5;
        ax.YLabel.String = 'Frequency (Hz)';
        ax.YTick = y_tick;
        ax.YLim = y_lim;
        ax.XLabel.String = 'Time (ms)';
        ax.XTick = [-2000 -1500 -1000 -500 0];
        ax.XLim = [-2000 0];
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
    
    cd(save_dir);
    
    if a == 1
        export_fig(f1,save_name,'-png');
    elseif a == 2
        export_fig(f2,save_name,'-png');
    end
end

%% Clean Workspace
clearvars -except summary