%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
prefix = 'MedEdFlynn_';
chan_name1 = 'Fz';
chan_name2 = 'Pz';
d_name = 'med_ed_wav.mat'; % Name of master data file
t_wind1 = [-1000 -500];
f_wind1 = [5 7];
t_wind2 = [-800 -500];
f_wind2 = [10 14];
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

for b = 1:62
    if strcmp(summary.chanlocs(b).labels,chan_name1) == 1
        chan_loc(b) = 1;
    elseif strcmp(summary.chanlocs(b).labels,chan_name2) == 1
        chan_loc(b) = 2;
    end
end

% Theta highlight
wav_wind1 = [min(t_wind1) min(f_wind1) 2;...
    max(t_wind1) min(f_wind1) 2;...
    max(t_wind1) max(f_wind1) 2;...
    min(t_wind1) max(f_wind1) 2];

% Alpha highlight
wav_wind2 = [min(t_wind2) min(f_wind2) 2;...
    max(t_wind2) min(f_wind2) 2;...
    max(t_wind2) max(f_wind2) 2;...
    min(t_wind2) max(f_wind2) 2];

clear a;

%% Plot Wavelets
disp('Plotting wavelets');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);

f1 = figure('Name','Wavelets',...
    'NumberTitle','off');

for a = 1:2
    for b = 1:2
        if a == 1
            analysis = 'template';
            save_name = 'WAV_Template';
        elseif a == 2
            analysis = 'decision';
            save_name = 'WAV_Decision';
        end
        
        if b == 1
            c_index = find(chan_loc == 1);
            shade_x = [wav_wind1(1,1) wav_wind1(2,1) wav_wind1(3,1) wav_wind1(4,1)];
            shade_y = [wav_wind1(1,2) wav_wind1(2,2) wav_wind1(3,2) wav_wind1(4,2)];
            shade_z = [wav_wind1(1,3) wav_wind1(2,3) wav_wind1(3,3) wav_wind1(4,3)];
            chan_name = chan_name1;
        elseif b == 2
            c_index = find(chan_loc == 2);
            shade_x = [wav_wind2(1,1) wav_wind2(2,1) wav_wind2(3,1) wav_wind2(4,1)];
            shade_y = [wav_wind2(1,2) wav_wind2(2,2) wav_wind2(3,2) wav_wind2(4,2)];
            shade_z = [wav_wind2(1,3) wav_wind2(2,3) wav_wind2(3,3) wav_wind2(4,3)];
            chan_name = chan_name2;
        end
        
        plotdata = squeeze(summary.(analysis).data{cond2}(c_index,:,1:499)) - squeeze(summary.(analysis).data{cond1}(c_index,:,1:499));
        freq = summary.(analysis).freq(1,1:59);
        time = summary.(analysis).time;
        
        subplot(2,1,b);
        s = surf(time,freq,plotdata);
        hold on
        shade = fill3(shade_x,shade_y,shade_z,0);
        hold off
        
        title(['Difference wavelet for ' chan_name ' during ' analysis]);
        set(gca,'ydir','normal');
        
        c = colorbar;
        c.TickDirection = 'out';
        c.Box = 'off';
        c.Label.String = 'Power (dB)';
        %c.Limits = wav_limits;
        drawnow;
        
        axpos = get(gca,'Position');
        cpos = c.Position;
        cpos(3) = 0.5*cpos(3);
        c.Position = cpos;
        drawnow;
        
        set(gca,'position',axpos);
        drawnow;
        
        ax = gca;
        %ax.CLim = wav_limits;
        ax.FontSize = 12;
        ax.FontName = 'Arial';
        ax.LineWidth = 1.5;
        ax.YLabel.String = 'Frequency (Hz)';
        ax.YTick = [0 5 10 15 20 25 30];
        ax.YLim = [0 30];
        ax.XLabel.String = 'Time (ms)';
        ax.XTick = [-2000 -1500 -1000 -500 0];
        ax.XLim = [-2000 0];
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
    export_fig(f1,save_name,'-png');
end

%% Clean Workspace
clearvars -except summary;