% Copyright (C) 2019 Jordan Middleton

% This function just corrects for a data labelling oversight when
% programming the experiment. The conflict scores were not labelled
% intuitively, so this function reorders them.

function subjectData = correctBehavioural(dataFile)
tempData = dataFile;
trialCount = size(tempData,1);

for trialCounter = 1:trialCount
    if tempData.conflict(trialCounter) == 1
        tempData.conflict(trialCounter) = 2;
    elseif tempData.conflict(trialCounter) == 4
        tempData.conflict(trialCounter) = 1;
    end
end

subjectData = tempData;
end
