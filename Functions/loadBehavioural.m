% Copyright (C) 2019 Jordan Middleton

% This function takes the trial data, summarized in a tab-delimited file,
% and imports it for analysis. The function inputs are [fileDirectory: the
% directory where the file is stored], [fileName: the name of the file to
% be imported]

function subjectData = loadBehavioural(fileDirectory,fileName)
% Change the path to the location where the file is stored
cd(fileDirectory);
% Import the desired file into a numeric array
subjectData = load(fileName);
% Convert the imported array into a table
subjectData = array2table(subjectData);
% Name each column in the data table accordingly
subjectData.Properties.VariableNames = {'subject','phase','block_count','block_total','trial_count','trial_total','RT','accuracy','disease','conflict','winloss','confidence','ALT','AST'};
end