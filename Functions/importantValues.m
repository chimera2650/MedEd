% Copyright (C) 2019 Jordan Middleton

% This function takes the output files from the associated experiment
% script and summarizes the important values as selected by each
% participant at the completion of the learning phase. The script outputs a
% table with the number of participants that selected each variable. Note
% that, since a participant was able to select multiple variables, the
% total selections will likely be greater than the number of participants.

% The inputs are as follows: [rawDirectory: the directory where all the
% participant output files are stored], [filePrefix: the text at the
% beginning of each participant file, to seperate them from other files in
% the directory], [keepList: a string of the numeric variables for each
% participant file to keep, in case there are some files in the directory
% that you wish to omit].

function values = importantValues(rawDirectory,filePrefix,keepList)
% Path to the directory in which the files are stored
cd(rawDirectory);
% Load a list of participants to keep, and split on comma into a list
fileKeep = strsplit(keepList,',');
% Determine number of files kept to define loop limits
fileNumber = length(fileKeep);

% This loop pulls the numbers from each column into a named vector to later
% be combined into a table
for fileCounter = 1:fileNumber
    fileName = [rawDirectory filePrefix fileKeep{fileCounter} '.mat'];
    load(fileName);
    hr(fileCounter,1) = ImportantValue(1);
    nbp(fileCounter,1) = ImportantValue(2);
    alt(fileCounter,1) = ImportantValue(3);
    ggt(fileCounter,1) = ImportantValue(4);
    spo2(fileCounter,1) = ImportantValue(5);
    ast(fileCounter,1) = ImportantValue(6);
    alp(fileCounter,1) = ImportantValue(7);
    temp(fileCounter,1) = ImportantValue(8);
    rr(fileCounter,1) = ImportantValue(9);
    ultra(fileCounter,1) = ImportantValue(10);
end

% Combine all data vectors into a single table
summaryTable = table(hr,nbp,alt,ggt,spo2,ast,alp,temp,rr,ultra);

% Summarize the above table into a singal value for each variable
summaryData = {'hr',sum(summaryTable.hr(:) == 1);...
    'nbp',sum(summaryTable.nbp(:) == 1);...
    'alt',sum(summaryTable.alt(:) == 1);...
    'ggt',sum(summaryTable.ggt(:) == 1);...
    'spo2',sum(summaryTable.spo2(:) == 1);...
    'ast',sum(summaryTable.ast(:) == 1);...
    'alp',sum(summaryTable.alp(:) == 1);...
    'temp',sum(summaryTable.temp(:) == 1);...
    'rr',sum(summaryTable.rr(:) == 1);...
    'ultra',sum(summaryTable.ultra(:) == 1)};

% Since there were two 'correct answers', it is also valuable to know how
% many participants selected both
conditionSummary = summaryTable.alt(:) == 1 & summaryTable.ast(:) == 1;
summaryData{11,1} = 'both';
summaryData{11,2} = sum(conditionSummary);
% Convert the total summary table into a numeric array to allow for percent
% calculation
number = cell2mat(summaryData(:,2));
percent = round((number./fileNumber).*100,2);
percent = num2cell(percent);
% Concatinate percentages into the summary table for export
summaryData = horzcat(summaryData,percent);
values.data = summaryTable;
values.summary = summaryData;
end