%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data files
masterName = 'MedEdFFT.mat';
% Define frequency band windows
delta = [1;3.5];
theta = [4;7.5];
alpha = [8;12.5];
beta = [13;30];
% Define channels of interest
channelFrontal = 'Fz';
channelParietal = 'Pz';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd';
    saveDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\MedEdStats.mat';
    addpath(genpath('C:\Users\chime\Documents\Github\MedEd\Functions'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd';
    saveDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\MedEdStats.mat';
    addpath(genpath('C:\Users\Jordan\Documents\Github\MedEd\Functions'));
end

clearvars comp

%% Load Data
% Temporarily add functions folder to path
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
disp('Loading data');
cd(masterDirectory);
load(masterName);
load('chanlocs.mat');
channelReference = chanlocs;
windows = table(delta,theta,alpha,beta);

clear alpha beta chanlocs delta masterDirectory masterName theta;

%% Statistics Analysis
disp('Running ttests');
[stimulusFz,statData(1,1,:,:,:)] = statsEEG(summary.stimulus.raw,windows,channelReference,channelFrontal);
[stimulusPz,statData(1,2,:,:,:)] = statsEEG(summary.stimulus.raw,windows,channelReference,channelParietal);
[responseFz,statData(2,1,:,:,:)] = statsEEG(summary.response.raw,windows,channelReference,channelFrontal);
[responsePz,statData(2,2,:,:,:)] = statsEEG(summary.response.raw,windows,channelReference,channelParietal);
statTable = vertcat(stimulusFz,stimulusPz,responseFz,responsePz);
statTable.Row = {'Fz Stimulus';'Pz Stimulus';'Fz Response';'Pz Response'};

clearvars channelFrontal channelParietal channelReference responseFz...
    responsePz stimulusFz stimulusPz summary windows;

%% Convert Data Table into Factors
disp('Consolidating factor table');
channelTable = [];

for channelCounter = 1:2
    channelData = squeeze(statData(:,channelCounter,:,:,:));
    
    if channelCounter == 1
        channelFactor(1:30,1) = {'Fz'};
    elseif channelCounter == 2
        channelFactor(1:30,1) = {'Pz'};
    end
    
    channelFactor = categorical(channelFactor);
    timeTable = [];
    
    for timeCounter = 1:2
        timeData = squeeze(channelData(timeCounter,:,:,:));
        
        if timeCounter == 1
            timeFactor(1:30,1) = {'stimulus'};
        elseif timeCounter == 2
            timeFactor(1:30,1) = {'response'};
        end
        
        timeFactor = categorical(timeFactor);
        conditionTable = [];
        
        for conditionCounter = 1:2
            conditionData = squeeze(timeData(:,:,conditionCounter));
            
            if conditionCounter == 1
                conditionFactor(1:30,1) = {'control'};
            elseif conditionCounter == 2
                conditionFactor(1:30,1) = {'conflict'};
            end
            
            conditionFactor = categorical(conditionFactor);
            bandTable = [];
            
            for bandCounter = 1:4
                bandData = squeeze(conditionData(bandCounter,:))';
                
                if bandCounter == 1
                    bandFactor(1:30,1) = {'delta'};
                elseif bandCounter == 2
                    bandFactor(1:30,1) = {'theta'};
                elseif bandCounter == 3
                    bandFactor(1:30,1) = {'alpha'};
                elseif bandCounter == 4
                    bandFactor(1:30,1) = {'beta'};
                end
                
                bandFactor = categorical(bandFactor);
                tempTable = table(channelFactor,timeFactor,conditionFactor,bandFactor,bandData,'VariableNames',{'channel','time','condition','band','value'});
                bandTable = vertcat(bandTable,tempTable);
                
                clearvars bandData bandFactor subjectFactor tempTable;
            end
            
            conditionTable = vertcat(conditionTable,bandTable);
            
            clearvars bandTable conditionData conditionFactor;
        end
        
        timeTable = vertcat(timeTable,conditionTable);
        
        clearvars conditionTable timeData timeFactor;
    end
    
    channelTable = vertcat(channelTable,timeTable);
    
    clearvars channelData channelFactor timeTable;
end

clearvars bandCounter channelCounter conditionCounter statData timeCounter;

%% Run ANOVA 
disp('Running 4-way ANOVA');
data = channelTable.value;
channel = channelTable.channel;
time = channelTable.time;
condition = channelTable.condition;
band = channelTable.band;
factorNames = {'channel','time','condition','band'};
[p,tbl,stats,terms] = anovan(data,{channel,time,condition,band},'varnames',...
    factorNames,'model','full','display','off');
results = multcompare(stats,'Dimension',[3 4],'display','off');
anova.p = p;
anova.tbl = tbl;
anova.stats = stats;
anova.terms = terms;
anova.results = results;

clearvars band channel condition data factorNames p results stats tbl terms time;

%% Consolidate Data
disp('Consolidating and saving data')
stats.table = statTable;
stats.data = channelTable;
stats.anova = anova;
save(saveDirectory,'stats');

clearvars -except stats;

disp('Analysis complete');