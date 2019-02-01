pcadata = summary.template.data;
load('C:\Users\Jordan\Documents\MATLAB\Data\MedEd\chanlocs.mat','chanlocs');
%pcadata = squeeze(pcadata(:,:,:,:,:));
pcadata = squeeze(pcadata(:,9,:,:,:));
%pcadata = reshape(pcadata,62,29500,2,30);
%pcadata = permute(pcadata,[2 1 3 4]);
time = summary.template.time;

cd('C:\Users\Jordan\Documents\MATLAB\MATLAB-EEG-PCA-Toolbox');

[PCAResults] = spatialPCA(pcadata,chanlocs,'VMAX',5);
[PCAResults] = temporalPCA(pcadata,time,'VMAX',5);


[PCAResults STPCAResults] = spatialTemporalPCA(pcadata,chanlocs,time,'VMAX','VMAX',5);