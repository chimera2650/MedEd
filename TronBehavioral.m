%% Code Info
% Written by Jordan Middleton 2018
clear;
clc;

%% Define Variables
prefix = 'Medical_DM_';
analysis = 'conflict';
sub_keep = '001,002,003,005,008,009,011,012,013,014,016,022,024,025,027,029,030,031,033,035,037,041,043,044,047,048,049,050,051,054';
comp = getenv('computername');

if strcmp(comp,'JORDAN-SURFACE') == 1
    working_dir = 'C:\Users\chime\Documents\MATLAB\Data\MedEd';
    working_dir1 = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral';
    working_dir2 = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\Behavioral\Raw';
    save_path = 'C:\Users\chime\Documents\MATLAB\Data\MedEd\med_ed.mat';
elseif strcmp(comp,'DESKTOP-U0FBSG7') == 1
    working_dir = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd';
    working_dir1 = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral';
    working_dir2 = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\Behavioral\Raw';
    save_path = 'C:\Users\Jordan\Documents\MATLAB\Data\MedEd\med_ed.mat';
end

clear comp

%% Load Data
cd(working_dir);
load('med_ed.mat');
cd(working_dir1);

if strcmp(analysis,'feedback') == 1
    subject_data = load('Medical_DM_Feedback.txt');
elseif strcmp(analysis,'conflict') == 1
    subject_data = load('Medical_DM_Conflict.txt');
end

subject_data = array2table(subject_data);
subject_data.Properties.VariableNames = {'subject','phase','block_count','block_total','trial_count','trial_total','RT','accuracy','disease','conflict','winloss','confidence','ALT','AST'};
nrow = height(subject_data);
ncol = width(subject_data);

%% Correct conflict scores
for x = 1:nrow
    if subject_data.conflict(x) == 1
        subject_data.conflict(x) = 2;
    elseif subject_data.conflict(x) == 4
        subject_data.conflict(x) = 1;
    end
end

clear x;

summary.behavioral = [];
summary.behavioral.ttest = [];
summary.behavioral.ttest = string(summary.behavioral.ttest);
summary.behavioral.ttest(2,1) = '0-1';
summary.behavioral.ttest(3,1) = '0-2';
summary.behavioral.ttest(4,1) = '1-2';
summary.behavioral.ttest(1,2) = 'accuracy';
summary.behavioral.ttest(1,3) = 'reactiontime';
summary.behavioral.ttest(1,4) = 'confidence';

%% Correlate conflict score
disp('Correlating conflict scores');

subject_data.cfscore = zeros(nrow,1);
subject_data.cfscore = (1-(((abs(subject_data.ALT-70)/60)+(abs(subject_data.AST-275)/225))*0.5));

summary.behavioral.correlation = [];
summary.behavioral.correlation = string(summary.behavioral.correlation);
summary.behavioral.correlation(1,1) = 'winloss';
summary.behavioral.correlation(2,1) = round(corr(subject_data.cfscore,subject_data.winloss),3);
summary.behavioral.correlation(1,2) = 'RT';
summary.behavioral.correlation(2,2) = round(corr(subject_data.cfscore,subject_data.RT),3);
summary.behavioral.correlation(1,3) = 'confidence';
summary.behavioral.correlation(2,3) = round(corr(subject_data.cfscore,subject_data.confidence),3);

clear nrow;
clear ncol;

%% Accuracy
disp('Summarizing accuracy data');

temp_data1 = NaN();
temp_data2 = NaN();
temp_data3 = NaN();
winloss = NaN(1,5);

% Create summary data
for i = 1:max(subject_data.subject)
    cond1 = subject_data.subject == i;
    temp_data1 = subject_data(cond1,:);
    
    for ii = 1:3
        cond2 = temp_data1.conflict == ii;
        temp_data2 = temp_data1(cond2,:);
        temp_data3(ii,1) = i;
        temp_data3(ii,2) = ii;
        temp_data3(ii,3) = mean(temp_data2.winloss);
        temp_data3(ii,4) = std(temp_data2.winloss);
        temp_data3(ii,5) = length(temp_data2.winloss);
    end
    
    winloss = [winloss; temp_data3];
end

cond3 = isnan(winloss(:,3));
winloss(cond3,:) = [];
winloss = array2table(winloss,'VariableNames',{'subject','conflict','mean','stdev','num'});
winloss.error = (winloss.stdev./sqrt(winloss.num));
ts = tinv(0.95,(winloss.num)-1);
winloss.ci = winloss.mean+(ts.*winloss.error);
accuracy.summary = winloss;

clear temp_data3;
clear ii;
clear cond3;
clear ts;

% Generate plot data
temp_data1 = NaN();
temp_data2 = NaN();
plotwinloss = NaN(1,4);

for i = 1:3
    cond1 = accuracy.summary.conflict == i;
    temp_data1 = accuracy.summary(cond1,:);
    temp_data2(i,1) = i;
    temp_data2(i,2) = mean(temp_data1.mean);
    temp_data2(i,3) = std(temp_data1.mean);
    temp_data2(i,4) = length(temp_data1.mean);
    plotwinloss = temp_data2;
end

cond2 = isnan(plotwinloss(:,2));
plotwinloss(cond2,:) = [];
plotwinloss = array2table(plotwinloss,'VariableNames',{'conflict','mean','stdev','num'});
plotwinloss.error = (plotwinloss.stdev./sqrt(plotwinloss.num));
ts = tinv(0.95,(plotwinloss.num)-1);
plotwinloss.ci = plotwinloss.mean+(ts.*plotwinloss.error);
accuracy.plot = plotwinloss;

clear i;
clear cond1;
clear cond2;
clear temp_data1;
clear temp_data2;
clear winloss;
clear plotwinloss;
clear ts;

% Repeated Measures ANOVA
for i = 1:3
    for ii = 1:(length(accuracy.summary.subject)/3)
        temp_data1(ii,1) = ii;
    end
    
    cond1 = accuracy.summary.conflict == i;
    temp_data2 = accuracy.summary.mean(cond1);
    temp_data1 = [temp_data1 temp_data2];
end

accuracy.anova.data = array2table(temp_data1,'VariableNames',{'subject','zero','one','two'});
meas = table([1 2 3]','VariableNames',{'Measurements'});
rm = fitrm(accuracy.anova.data,'zero-two~subject','WithinDesign',meas);
accuracy.anova.output = ranova(rm);

clear cond1;
clear cond2;
clear i;
clear ii;
clear meas;
clear rm;
clear temp_data1;
clear temp_data2;

% Within Confidence Intervals
ci = [];

for i = 1:max(accuracy.summary.subject)
    cond1 = accuracy.summary.subject(:) == i;
    temp_data1 = accuracy.summary.mean(cond1);
    temp_data2 = mean(temp_data1);
    ci(end+1,:) = temp_data2;
end

cond2 = isnan(ci(:,1));
ci(cond2,:) = [];
accuracy.ci.data = ci;

clear ci;

ci(1,1) = mean(accuracy.ci.data);
ci(1,2) = std(accuracy.ci.data);
ci(1,3) = length(accuracy.ci.data);
ci(1,4) = ci(1,2)/sqrt(ci(1,3)-1);
ci(1,5) = accuracy.anova.output.MeanSq(2);
ts = tinv(0.95,ci(1,3)-1);
ci(1,6) = sqrt(ci(1,5)/ci(1,3))*(ts);
accuracy.ci.within = ci;

clear ci;
clear cond1;
clear cond2;
clear i;
clear temp_data1;
clear temp_data2;
clear ts;

% Significance testing
temp_data = NaN();
sigaccuracy = NaN(length(unique(accuracy.summary.subject)),3);

for i = 1:3
    cond1 = accuracy.summary.conflict == i;
    temp_data = accuracy.summary.mean(cond1,:);
    sigaccuracy(:,i) = temp_data;
end

sigaccuracy = array2table(sigaccuracy,'VariableNames',{'c0','c1','c2'});
accuracy.significance = sigaccuracy;

clear cond1;
clear i;
clear temp_data;
clear sigaccuracy;

summary.behavioral.ttest(2,2) = ttest(accuracy.significance.c0,accuracy.significance.c1);
summary.behavioral.ttest(3,2) = ttest(accuracy.significance.c0,accuracy.significance.c2);
summary.behavioral.ttest(4,2) = ttest(accuracy.significance.c1,accuracy.significance.c2);

%% Reaction Time
disp('Summarizing reaction time data');

temp_data1 = NaN();
temp_data2 = NaN();
temp_data3 = NaN();
RT = NaN(1,5);

for i = 1:max(subject_data.subject)
    cond1 = subject_data.subject == i;
    temp_data1 = subject_data(cond1,:);
    
    for ii = 1:3
        cond2 = temp_data1.conflict == ii;
        temp_data2 = temp_data1(cond2,:);
        temp_data3(ii,1) = i;
        temp_data3(ii,2) = ii;
        temp_data3(ii,3) = mean(temp_data2.RT);
        temp_data3(ii,4) = std(temp_data2.RT);
        temp_data3(ii,5) = length(temp_data2.RT);
    end
    
    RT = [RT; temp_data3];
end

cond3 = isnan(RT(:,3));
RT(cond3,:) = [];
RT = array2table(RT,'VariableNames',{'subject','conflict','mean','stdev','num'});
RT.error = (RT.stdev./sqrt(RT.num));
ts = tinv(0.95,(RT.num)-1);
RT.ci = RT.mean+(ts.*RT.error);
reactiontime.summary = RT;

clear temp_data3;
clear ii;
clear cond3;
clear ts;

temp_data1 = NaN();
temp_data2 = NaN();
plotRT = NaN(1,4);

for i = 1:3
    cond1 = reactiontime.summary.conflict == i;
    temp_data1 = reactiontime.summary(cond1,:);
    temp_data2(i,1) = i;
    temp_data2(i,2) = mean(temp_data1.mean);
    temp_data2(i,3) = std(temp_data1.mean);
    temp_data2(i,4) = length(temp_data1.mean);
    plotRT = temp_data2;
end

cond2 = isnan(plotRT(:,2));
plotRT(cond2,:) = [];
plotRT = array2table(plotRT,'VariableNames',{'conflict','mean','stdev','num'});
plotRT.error = (plotRT.stdev./sqrt(plotRT.num));
ts = tinv(0.95,(plotRT.num)-1);
plotRT.ci = plotRT.mean+(ts.*plotRT.error);
reactiontime.plot = plotRT;

clear i;
clear cond1;
clear cond2;
clear temp_data1;
clear temp_data2;
clear RT;
clear plotRT;
clear ts;

% Repeated Measures ANOVA
for i = 1:3
    for ii = 1:(length(reactiontime.summary.subject)/3)
        temp_data1(ii,1) = ii;
    end
    
    cond1 = reactiontime.summary.conflict == i;
    temp_data2 = reactiontime.summary.mean(cond1);
    temp_data1 = [temp_data1 temp_data2];
end

reactiontime.anova.data = array2table(temp_data1,'VariableNames',{'subject','zero','one','two'});
meas = table([1 2 3]','VariableNames',{'Measurements'});
rm = fitrm(reactiontime.anova.data,'zero-two~subject','WithinDesign',meas);
reactiontime.anova.output = ranova(rm);

clear cond1;
clear cond2;
clear i;
clear ii;
clear meas;
clear rm;
clear temp_data1;
clear temp_data2;

% Within Confidence Intervals
ci = [];

for i = 1:max(reactiontime.summary.subject)
    cond1 = reactiontime.summary.subject(:) == i;
    temp_data1 = reactiontime.summary.mean(cond1);
    temp_data2 = mean(temp_data1);
    ci(end+1,:) = temp_data2;
end

cond2 = isnan(ci(:,1));
ci(cond2,:) = [];
reactiontime.ci.data = ci;
clear ci;

ci(1,1) = mean(reactiontime.ci.data);
ci(1,2) = std(reactiontime.ci.data);
ci(1,3) = length(reactiontime.ci.data);
ci(1,4) = ci(1,2)/sqrt(ci(1,3)-1);
ci(1,5) = reactiontime.anova.output.MeanSq(2);
ts = tinv(0.95,ci(1,3)-1);
ci(1,6) = sqrt(ci(1,5)/ci(1,3))*(ts);
reactiontime.ci.within = ci;

clear ci;
clear cond1;
clear cond2;
clear i;
clear temp_data1;
clear temp_data2;
clear ts;

% Significance testing
temp_data1 = NaN();
temp_data2 = NaN(length(unique(reactiontime.summary.subject)),1);
sigRT = NaN(length(unique(reactiontime.summary.subject)),3);

for i = 1:3
    cond1 = reactiontime.summary.conflict == i;
    temp_data1 = reactiontime.summary.mean(cond1,:);
    temp_data2(:,i) = temp_data1;
    sigRT = temp_data2;
end

sigRT = array2table(sigRT,'VariableNames',{'c0','c1','c2'});
reactiontime.significance = sigRT;

clear cond1;
clear i;
clear temp_data1;
clear temp_data2;
clear sigRT;

summary.behavioral.ttest(2,3) = ttest(reactiontime.significance.c0,reactiontime.significance.c1);
summary.behavioral.ttest(3,3) = ttest(reactiontime.significance.c0,reactiontime.significance.c2);
summary.behavioral.ttest(4,3) = ttest(reactiontime.significance.c1,reactiontime.significance.c2);

%% Confidence
disp('Summarizing confidence data');

temp_data1 = NaN();
temp_data2 = NaN();
temp_data3 = NaN();
conf = NaN(1,5);

for i = 1:max(subject_data.subject)
    cond1 = subject_data.subject == i;
    temp_data1 = subject_data(cond1,:);
    
    for ii = 1:3
        cond2 = temp_data1.conflict == ii;
        temp_data2 = temp_data1(cond2,:);
        temp_data3(ii,1) = i;
        temp_data3(ii,2) = ii;
        temp_data3(ii,3) = mean(temp_data2.confidence);
        temp_data3(ii,4) = std(temp_data2.confidence);
        temp_data3(ii,5) = length(temp_data2.confidence);
    end
    
    conf = [conf; temp_data3];
end

cond3 = isnan(conf(:,3));
conf(cond3,:) = [];
conf = array2table(conf,'VariableNames',{'subject','conflict','mean','stdev','num'});
conf.error = (conf.stdev./sqrt(conf.num));
ts = tinv(0.95,(conf.num)-1);
conf.ci = conf.mean+(ts.*conf.error);
confidence.summary = conf;

clear temp_data3;
clear ii;
clear cond3;
clear ts;

temp_data1 = NaN();
temp_data2 = NaN();
plotconfidence = NaN(1,4);

for i = 1:3
    cond1 = confidence.summary.conflict == i;
    temp_data1 = confidence.summary(cond1,:);
    temp_data2(i,1) = i;
    temp_data2(i,2) = mean(temp_data1.mean);
    temp_data2(i,3) = std(temp_data1.mean);
    temp_data2(i,4) = length(temp_data1.mean);
    plotconfidence = temp_data2;
end

cond2 = isnan(plotconfidence(:,2));
plotconfidence(cond2,:) = [];
plotconfidence = array2table(plotconfidence,'VariableNames',{'conflict','mean','stdev','num'});
plotconfidence.error = (plotconfidence.stdev./sqrt(plotconfidence.num));
ts = tinv(0.95,(plotconfidence.num)-1);
plotconfidence.ci = plotconfidence.mean+(ts.*plotconfidence.error);
confidence.plot = plotconfidence;

clear i;
clear cond1;
clear cond2;
clear temp_data1;
clear temp_data2;
clear conf;
clear plotconfidence;
clear ts;

% Repeated Measures ANOVA
for i = 1:3
    for ii = 1:(length(confidence.summary.subject)/3)
        temp_data1(ii,1) = ii;
    end
    
    cond1 = confidence.summary.conflict == i;
    temp_data2 = confidence.summary.mean(cond1);
    temp_data1 = [temp_data1 temp_data2];
end

confidence.anova.data = array2table(temp_data1,'VariableNames',{'subject','zero','one','two'});
meas = table([1 2 3]','VariableNames',{'Measurements'});
rm = fitrm(confidence.anova.data,'zero-two~subject','WithinDesign',meas);
confidence.anova.output = ranova(rm);

clear cond1;
clear cond2;
clear i;
clear ii;
clear meas;
clear rm;
clear temp_data1;
clear temp_data2;

% Within Confidence Intervals
ci = [];

for i = 1:max(confidence.summary.subject)
    cond1 = confidence.summary.subject(:) == i;
    temp_data1 = confidence.summary.mean(cond1);
    temp_data2 = mean(temp_data1);
    ci(end+1,:) = temp_data2;
end

cond2 = isnan(ci(:,1));
ci(cond2,:) = [];
confidence.ci.data = ci;

clear ci;

ci(1,1) = mean(confidence.ci.data);
ci(1,2) = std(confidence.ci.data);
ci(1,3) = length(confidence.ci.data);
ci(1,4) = ci(1,2)/sqrt(ci(1,3)-1);
ci(1,5) = confidence.anova.output.MeanSq(2);
ts = tinv(0.95,ci(1,3)-1);
ci(1,6) = sqrt(ci(1,5)/ci(1,3))*(ts);
confidence.ci.within = ci;

clear ci;
clear cond1;
clear cond2;
clear i;
clear temp_data1;
clear temp_data2;
clear ts;

% Significance testing
temp_data1 = NaN();
temp_data2 = NaN(length(unique(confidence.summary.subject)),1);
sigconf = NaN(length(unique(confidence.summary.subject)),3);

for i = 1:3
    cond1 = confidence.summary.conflict == i;
    temp_data1 = confidence.summary.mean(cond1,:);
    temp_data2(:,i) = temp_data1;
    sigconf = temp_data2;
end

sigconf = array2table(sigconf,'VariableNames',{'c0','c1','c2'});
confidence.significance = sigconf;
clear cond1;
clear i;
clear temp_data1;
clear temp_data2;
clear sigconf;
clear subject_data;

summary.behavioral.ttest(2,4) = ttest(confidence.significance.c0,confidence.significance.c1);
summary.behavioral.ttest(3,4) = ttest(confidence.significance.c0,confidence.significance.c2);
summary.behavioral.ttest(4,4) = ttest(confidence.significance.c1,confidence.significance.c2);

%% Summarize Important Variables
disp('Summarizing important variables');

cd(working_dir2);
sub_num = strsplit(sub_keep,',');
file_num = length(sub_num);

for i = 1:file_num
    file_name = [working_dir2 prefix sub_num{i} '.mat'];
    load(file_name);
    hr(i,1) = ImportantValue(1);
    nbp(i,1) = ImportantValue(2);
    alt(i,1) = ImportantValue(3);
    ggt(i,1) = ImportantValue(4);
    spo2(i,1) = ImportantValue(5);
    ast(i,1) = ImportantValue(6);
    alp(i,1) = ImportantValue(7);
    temp(i,1) = ImportantValue(8);
    rr(i,1) = ImportantValue(9);
    ultra(i,1) = ImportantValue(10);
end

summary_table = table(hr,nbp,alt,ggt,spo2,ast,alp,temp,rr,ultra);

summary_data = {'hr',sum(summary_table.hr(:) == 1);...
    'nbp',sum(summary_table.nbp(:) == 1);...
    'alt',sum(summary_table.alt(:) == 1);...
    'ggt',sum(summary_table.ggt(:) == 1);...
    'spo2',sum(summary_table.spo2(:) == 1);...
    'ast',sum(summary_table.ast(:) == 1);...
    'alp',sum(summary_table.alp(:) == 1);...
    'temp',sum(summary_table.temp(:) == 1);...
    'rr',sum(summary_table.rr(:) == 1);...
    'ultra',sum(summary_table.ultra(:) == 1)};

cond1 = summary_table.alt(:) == 1 & summary_table.ast(:) == 1;
summary_data{11,1} = 'both';
summary_data{11,2} = sum(cond1);

num = cell2mat(summary_data(:,2));
percent = round((num./file_num).*100,2);
percent = num2cell(percent);
summary_data = horzcat(summary_data,percent);

variables.data = summary_table;
variables.summary = summary_data;

clear alp;
clear alt;
clear ast;
clear cond1;
clear file_name;
clear file_num;
clear ggt;
clear hr;
clear i;
clear ImportantValue;
clear nbp;
clear num;
clear percent;
clear rr;
clear spo2;
clear sub_num;
clear summary_data;
clear summary_table
clear temp;
clear ultra;

%% Consolidate Data
disp('Consolidating and saving data');
summary.behavioral.accuracy = accuracy;
summary.behavioral.reactiontime = reactiontime;
summary.behavioral.confidence = confidence;
summary.behavioral.variables = variables;

%% Save Data
save(save_path,'summary');

%% Clean Up Workspace
clear accuracy;
clear confidence;
clear reactiontime;
clear variables;