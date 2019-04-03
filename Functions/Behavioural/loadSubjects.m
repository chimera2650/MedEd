function subjectData = loadSubjects(fileDirectory,fileName)
cd(fileDirectory);
subjectData = load(fileName);
subjectData = array2table(subjectData);
subjectData.Properties.VariableNames = {'subject','phase','block_count','block_total','trial_count','trial_total','RT','accuracy','disease','conflict','winloss','confidence','ALT','AST'};
end