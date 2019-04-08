% This function creates a table that reports the correlation between eact
% behavioural metric [accuracy,reaction time,confidence] and conflict
% score.

function correlation = correlateBehavioural(dataFile)
disp('Correlating conflict scores');
tempData = dataFile;
% Calculate conflict scores by normalizing relevant variables into a
% percent format
tempData.cfscore = (1-(((abs(tempData.ALT-70)/60)+(abs(tempData.AST-275)/225))*0.5));
% Determine linear correlations for each of the three variables (accuracy,
% reaction time, and confidence) to conflict score
accuracy = round(corr(tempData.cfscore,tempData.winloss),3);
reactionTime = round(corr(tempData.cfscore,tempData.RT),3);
confidence = round(corr(tempData.cfscore,tempData.confidence),3);
% Combine three correlations into a single table for export
correlationData = table(accuracy,reactionTime,confidence);
correlation = correlationData;
end