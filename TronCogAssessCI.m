%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
prefix = 'CogAssess_flynn_';
chan_name1 = 'FCz';
chan_name2 = 'Pz';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Cog Assess\RewP';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\Cog Assess\P300';
    save_path = 'C:\Users\chime\Documents\MATLAB\MedEd\Data\cog_assess.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Cog Assess\RewP';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\Cog Assess\P300';
    save_path = 'C:\Users\Jordan\Documents\MATLAB\MedEd\Data\cog_assess.mat';
end

clear comp

%% Load Data
cd(working_dir);
load('cog_assess.mat');

for i = 1:62
    if strcmp(cog_assess.chanlocs(i).labels,chan_name1) == 1
        chan_loc(i) = 1;
    elseif strcmp(cog_assess.chanlocs(i).labels,chan_name2) == 1
        chan_loc(i) = 2;
    else
        chan_loc(i) = 0;
    end
end

c_index1 = find(chan_loc == 1);
c_index2 = find(chan_loc == 2);

clear chan_loc;
clear i;

%% ERP CI
for y = 1:2
    if y == 1
        cd(working_dir1);
        analysis = 'rewp';
    elseif y == 2
        cd(working_dir2);
        analysis = 'p300';
    end
    
    filenames = dir(strcat(prefix,'*'));   % Get a count of file number
    file_num = length(filenames);
    
    for i = 1:200
        subject = num2str((i*4)-200);
        for x = 1:file_num
            subject_data = importdata(filenames(x).name); % Import subject data
            summary_data(x,1) = subject_data.ERP.data{1}(c_index1,i);
            summary_data(x,2) = subject_data.ERP.data{2}(c_index1,i);
        end
        
        disp(['Calculating ERP confidence intervals at ' subject ' ms']);
        
        cond1 = isnan(summary_data(:,2));
        summary_data(cond1,:) = [];
        summary_data(25,:) = [];
        [p,tbl] = anova1(summary_data,{'win','loss'},'off');
        
        summary_data = mean(summary_data,2);
        
        ci_data(i,1) = mean(summary_data);
        ci_data(i,2) = std(summary_data);
        ci_data(i,3) = length(summary_data);
        ci_data(i,4) = ci_data(i,2)/sqrt(ci_data(i,3)-1);
        ts = tinv(0.95,ci_data(i,3)-1);
        ci_data(i,5) = tbl{3,4};
        ci_data(i,6) = sqrt(ci_data(i,5)/ci_data(i,3))*(ts);
    end
    
    cog_assess.(analysis).ci_data = ci_data;
    
    clear ci_data;
    clear cond1;
    clear i;
    clear p;
    clear subject_data;
    clear summary_data;
    clear tbl;
    clear ts;
    clear x;
end

clear y;

%% ERP T-Tests
for y = 1:2
    if y == 1
        cd(working_dir1);
        analysis = 'rewp';
        c_index = c_index1;
    elseif y == 2
        cd(working_dir2);
        analysis = 'p300';
        c_index = c_index2;
    end
    for i = 1:200
        subject = num2str((i*4)-200);
        for x = 1:file_num
            subject_data = importdata(filenames(x).name); % Import subject data
            summary_data(x,1) = subject_data.ERP.data{1}(c_index,i);
            summary_data(x,2) = subject_data.ERP.data{2}(c_index,i);
        end
        
        disp(['Calculating ERP t-tests at ' subject ' ms']);
        
        cond1 = isnan(summary_data(:,2));
        summary_data(cond1,:) = [];
        summary_data(25,:) = [];
        a = summary_data(:,1);
        b = summary_data(:,2);
        
        [h,p] = ttest(a,b,'tail','both');
        cond_ttest(i,1) = p;
    end
    
    cog_assess.(analysis).ttest = cond_ttest;
    
    clear a;
    clear b;
    clear c_index;
    clear cond_ttest;
    clear cond1;
    clear h;
    clear i;
    clear p;
    clear summary_data;
    clear x;
end

clear y;

%% Save Data
save(save_path,'cog_assess');

%% Clean Workspace
clear c_index1;
clear c_index2;
clear file_num;
clear filenames;
clear subject_data;
