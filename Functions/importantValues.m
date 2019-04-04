function values = importantValues(rawDirectory,filePrefix,keepList)
cd(rawDirectory);
fileKeep = strsplit(keepList,',');
fileNumber = length(fileKeep);

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

summaryTable = table(hr,nbp,alt,ggt,spo2,ast,alp,temp,rr,ultra);

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

conditionSummary = summaryTable.alt(:) == 1 & summaryTable.ast(:) == 1;
summaryData{11,1} = 'both';
summaryData{11,2} = sum(conditionSummary);
number = cell2mat(summaryData(:,2));
percent = round((number./fileNumber).*100,2);
percent = num2cell(percent);
summaryData = horzcat(summaryData,percent);
values.data = summaryTable;
values.summary = summaryData;
end