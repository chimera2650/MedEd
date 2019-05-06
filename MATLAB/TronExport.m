%% Code Info
% Copyright (C) 2019 Jordan Middleton
clear;
clc;

%% Define Variables
% Name of master data file
erpName = 'MedEdERP.mat';
fftName = 'MedEdFFT.mat';
stimulusName = 'MedEdStimulusWAV.mat';
responseName = 'MedEdResponseWAV.mat';
pcaName = 'MedEdPCA.mat';
behaviouralName = 'MedEdBehavioural.mat';

% Find the name of the current computer
comp = getenv('computername');

% This section is just to make life easier when working on different
% computers with difference file structures. If you are using only one
% computer, remove the IF statements and redefine directories
if strcmp(comp,'JORDAN-SURFACE') == 1
    masterDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd';
    erpDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\R\ERP Data';
    fftDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\R\FFT Data';
    wavDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\R\WAV Data';
    pcaDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\R\PCA Data';
    behaviouralDirectory = 'C:\Users\chime\Documents\Github\Data\MedEd\R\Behavioural Data';
    addpath(genpath('C:\Users\chime\Documents\Github\MedEd\Functions\'));
elseif strcmp(comp,'OLAV-PATTY') == 1
    masterDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd';
    erpDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\R\ERP Data';
    fftDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\R\FFT Data';
    wavDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\R\WAV Data';
    pcaDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\R\PCA Data';
    behaviouralDirectory = 'C:\Users\Jordan\Documents\Github\Data\MedEd\R\Behavioural Data';
    addpath(genpath('C:\Users\Jordan\Documents\Github\MedEd\Functions\'));
end

clearvars comp;

%% Load Data
% Temporarily add functions folder to path
% Change directory to where master data file is located, if at all, as well
% as cannel reference file
cd(masterDirectory);
load('chanlocs.mat');
channelReference = chanlocs;

clearvars chanlocs;

%% Export data ERP data
cd(masterDirectory);
load(erpName);
exportLearner = eegExport(summary.erp.raw,'FCz',channelReference,'ERP');
cd(erpDirectory);
csvwrite('learner.csv',exportLearner);
exportNonlearner = eegExport(summary.erpnl.raw,'FCz',channelReference,'ERP');
csvwrite('nonlearner.csv',exportNonlearner);
exportTime = summary.erp.time;
csvwrite('time.csv',exportTime);

clearvars erpDirectory erpName exportLearner exportNonlearner exportTime summary;

%% Export FFT data
cd(masterDirectory);
load(fftName);
exportStimulusFz = eegExport(summary.stimulus.raw(:,1:59,:,30),'Fz',channelReference,'FFT');
cd(fftDirectory);
csvwrite('stimulusFz.csv',exportStimulusFz);
exportStimulusPz = eegExport(summary.stimulus.raw(:,1:59,:,30),'Pz',channelReference,'FFT');
csvwrite('stimulusPz.csv',exportStimulusPz);
exportResponseFz = eegExport(summary.response.raw(:,1:59,:,30),'Fz',channelReference,'FFT');
csvwrite('responseFz.csv',exportResponseFz);
exportResponsePz = eegExport(summary.response.raw(:,1:59,:,30),'Pz',channelReference,'FFT');
csvwrite('responsePz.csv',exportResponsePz);
exportFrequency = summary.stimulus.frequency;
csvwrite('frequency.csv',exportFrequency);

clearvars exportFrequency exportResponseFz exportResponsePz exportStimulusFz ...
    exportStimulusPz fftDirectory fftName summary;

%% Export WAV data
cd(masterDirectory);
load(stimulusName);
exportStimulusFz = eegExport(summary.raw,'Fz',channelReference,'WAV');
cd(wavDirectory);
csvwrite('stimulusFz.csv',exportStimulusFz);
exportStimulusPz = eegExport(summary.raw,'Pz',channelReference,'WAV');
csvwrite('stimulusPz.csv',exportStimulusPz);
exportStimulusSigFz = eegExport(summary.ttest,'Fz',channelReference,'STAT');
csvwrite('stimulusSigFz.csv',exportStimulusSigFz);
exportStimulusSigPz = eegExport(summary.ttest,'Pz',channelReference,'STAT');
csvwrite('stimulusSigPz.csv',exportStimulusSigPz);
exportStimulusTime = summary.time;
csvwrite('stimulusTime.csv',exportStimulusTime);
cd(masterDirectory);
load(responseName);
exportResponseFz = eegExport(summary.raw,'Fz',channelReference,'WAV');
cd(wavDirectory);
csvwrite('responseFz.csv',exportResponseFz);
exportResponsePz = eegExport(summary.raw,'Pz',channelReference,'WAV');
csvwrite('responsePz.csv',exportResponsePz);
exportResponseSigFz = eegExport(summary.ttest,'Fz',channelReference,'STAT');
csvwrite('responseSigFz.csv',exportResponseSigFz);
exportResponseSigPz = eegExport(summary.ttest,'Pz',channelReference,'STAT');
csvwrite('responseSigPz.csv',exportResponseSigPz);
exportResponseTime = summary.time;
csvwrite('responseTime.csv',exportResponseTime);
exportFrequency = summary.frequency;
csvwrite('frequency.csv',exportFrequency);

clearvars exportFrequency exportResponseFz exportResponsePz exportResponseTime...
    exportStimulusFz exportStimulusPz exportStimulusTime responseName...
    stimulusName summary wavDirectory;

%% Export PCA data
cd(masterDirectory);
load(pcaName);
exportStimulusTemporalPlot = eegExport(PCA.stimulus.temporal.plotData,[],[],'PCA');
cd(pcaDirectory);
csvwrite('stimulusTemporalPlot.csv',exportStimulusTemporalPlot);
exportStimulusTemporalVariance = eegExport(PCA.stimulus.temporal.varianceData,[],[],'PCA');
csvwrite('stimulusTemporalVariance.csv',exportStimulusTemporalVariance);
exportStimulusFrequencyPlot = eegExport(PCA.stimulus.frequency.plotData,[],[],'PCA');
csvwrite('stimulusFrequencyPlot.csv',exportStimulusFrequencyPlot);
exportStimulusFrequencyVariance = eegExport(PCA.stimulus.frequency.varianceData,[],[],'PCA');
csvwrite('stimulusFrequencyVariance.csv',exportStimulusFrequencyVariance);
exportResponseTemporalPlot = eegExport(PCA.response.temporal.plotData,[],[],'PCA');
csvwrite('responseTemporalPlot.csv',exportResponseTemporalPlot);
exportResponseTemporalVariance = eegExport(PCA.response.temporal.varianceData,[],[],'PCA');
csvwrite('responseTemporalVariance.csv',exportResponseTemporalVariance);
exportResponseFrequencyPlot = eegExport(PCA.response.frequency.plotData,[],[],'PCA');
csvwrite('responseFrequencyPlot.csv',exportResponseFrequencyPlot);
exportResponseFrequencyVariance = eegExport(PCA.response.frequency.varianceData,[],[],'PCA');
csvwrite('responseFrequencyVariance.csv',exportResponseFrequencyVariance);
exportStimulusTime = PCA.stimulus.temporal.time;
csvwrite('stimulusTime.csv',exportStimulusTime);
exportResponseTime = PCA.response.temporal.time;
csvwrite('responseTime.csv',exportResponseTime);
exportFrequency = PCA.response.frequency.frequency;
csvwrite('frequency.csv',exportFrequency);

clearvars exportFrequency exportResponseFrequencyPlot exportResponseFrequencyVariance ...
    exportResponseTemporalPlot exportResponseTemporalVariance exportResponseTime ...
    exportStimulusFrequencyPlot exportStimulusFrequencyVariance exportStimulusTemporalPlot ...
    exportStimulusTemporalVariance exportStimulusTime PCA pcaDirectory pcaName

%% Export Behavioural Data
cd(masterDirectory);
load(behaviouralName);
exportAccuracy = eegExport(behavioural.accuracy.summary,[],[],'behavioural');
cd(behaviouralDirectory);
csvwrite('accuracy.csv',exportAccuracy);
exportReactionTime = eegExport(behavioural.reactionTime.summary,[],[],'behavioural');
csvwrite('reactionTime.csv',exportReactionTime);
exportConfidence = eegExport(behavioural.confidence.summary,[],[],'behavioural');
csvwrite('confidence.csv',exportConfidence);

clearvars behavioural behaviouralDirectory behaviouralName exportAccuracy exportConfidence ...
    exportReactionTime;
