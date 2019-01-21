%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Set Variables
chan_name1 = 'Fz';
chan_name2 = 'Pz';
d_name = 'med_ed_wav.mat'; % Name of master data file
t_wind1 = [-1000 -500];
f_wind1 = [5 7];
t_wind2 = [-800 -500];
f_wind2 = [10 14];
topo_limits = [-1.25 1.25];
cond1 = 1;
cond2 = 3;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    master_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    topo_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Decision';
    save_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Export';
    set(0,'DefaultFigurePosition','remove');
elseif strcmp(comp,'OLAV-PATTY') == 1
    master_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    topo_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Decision';
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

clear a;

%% Plot Topography
disp('Plotting topographies');
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);

f1 = figure('Name','Topography',...
    'NumberTitle','off');

for a = 2:2
    for b = 1:2
        if a == 1
            analysis = 'template';
            save_name = 'Topo_Template';
        elseif a == 2
            analysis = 'decision';
            save_name = 'Topo_Decision';
        end
        
        if b == 1
            t_wind = t_wind1;
            f_wind = f_wind1;
            t_lab = 'theta';
            chan_name = chan_name1;
        elseif b == 2
            t_wind = t_wind2;
            f_wind = f_wind2;
            t_lab = 'alpha';
            chan_name = chan_name2;
        end
        
        t_index = dsearchn(summary.(analysis).time',t_wind');
        f_index = dsearchn(summary.(analysis).freq',f_wind');
        
        for ii = 1:3
            t_data{ii} = squeeze(mean(summary.(analysis).data{ii}(:,f_index(1):f_index(2),t_index(1):t_index(2)),3));
        end
        
        topodata = t_data{cond2}-t_data{cond1};
        t_vector = squeeze(mean(topodata,2));
        t_min = min(t_vector);
        t_max = max(t_vector);
        
        subplot(1,2,b);
        topo = topoplot(t_vector,summary.chanlocs,...
            'maplimits',topo_limits,...
            'style','map',...
            'electrodes','on',...
            'nosedir','+X',...
            'headrad','rim',...
            'shading','interp',...
            'conv','on',...
            'emarker',{'o','k',[],1},...
            'numcontour',32,...
            'whitebk','on',...
            'colormap',colors);
        
        title(['Topography for ' t_lab ' activity at ' chan_name ' during ' analysis]);
        colormap(colors);
        
        ax = gca;
        ax.FontSize = 12;
        ax.CLim = topo_limits;
        
        c = colorbar();
        c.TickDirection = 'out';
        c.Box = 'off';
        c.Label.String = 'Power (dB)';
        c.FontSize = 12;
        c.Limits = topo_limits;
        drawnow;
    end
    
    cd(save_dir);
    export_fig(f1,save_name,'-png');
end

%% Clean Up Workspace
clearvars -except summary