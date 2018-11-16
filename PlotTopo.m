%% Code Info
% Written by Jordan Middleton 2018
clc;
clear;
close all;

%% Define Variables
t_wind1 = [-1000 -500];
t_wind2 = [-800 -500];
f_wind1 = [5 7];
f_wind2 = [10 14];
limits = [-1.25 1.25];
cond1 = 1;
cond2 = 3;
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
end

%% Load Variables
cd(working_dir);
load('final_summary.mat');
colors5 = cbrewer('div','RdBu',64,'PCHIP');
colors5 = flipud(colors);

%% Plot Topography
f5 = figure(5);
for i = 1:2
    if i == 1
        t_wind = t_wind1;
        f_wind = f_wind1;
        t_lab = 'Theta burst preceding decision';
    elseif i == 2
        t_wind = t_wind2;
        f_wind = f_wind2;
        t_lab = 'Alpha burst preceding decision';
    end
    
    t_index = dsearchn(final_summary.wavelet.time',t_wind');
    f_index = dsearchn(final_summary.wavelet.freq',f_wind');
    
    for ii = 1:3
        t_data{ii} = squeeze(mean(final_summary.wavelet.data{ii}(:,f_index(1):f_index(2),t_index(1):t_index(2)),3));
    end
    
    topodata = t_data{cond1}-t_data{cond2};
    t_vector = squeeze(mean(topodata,2));
    t_min = min(t_vector);
    t_max = max(t_vector);
    
    subplot(1,2,i);
    topo = topoplot(t_vector,final_summary.chanlocs,...
        'maplimits',limits,...
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
    
    title(t_lab)
    colormap(colors);
    
    ax = gca;
    ax.FontSize = 12;
    
    c = colorbar();
    c.TickDirection = 'out';
    c.Box = 'off';
    c.Label.String = 'Power (dB)';
    c.FontSize = 12;
    c.Limits = limits;
    drawnow;
end

%% Clean up workspace
clear ax;
clear c;
clear colors;
clear cond1;
clear cond2;
clear f_index;
clear f_wind;
clear f_wind1;
clear f_wind2;
clear i;
clear limits;
clear t_data;
clear t_data;
clear t_index;
clear t_lab;
clear t_vector;
clear t_wind;
clear t_wind1;
clear t_wind2;
clear topodata;
