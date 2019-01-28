clear all
filenames = dir(strcat('MedEd','*'));
colors = cbrewer('div','RdBu',64,'PCHIP');
colors = flipud(colors);


plot_num = 1;
for subjects = 1:30
disp(num2str(subjects));
clear WAV
load(filenames(subjects).name);
%subplot(10,2,plot_num)
%surf(squeeze(WAV.data{1,1}(28,1:29,51:550)));shading interp; view(2);
new_data(subjects,:,:,1) = squeeze(WAV.data{1,1}(28,1:29,51:550));
set(gca,'clim',[0 2]);        colormap(colors);
plot_num = plot_num+1;
%subplot(10,2,plot_num)
%surf(squeeze(WAV.data{1,3}(28,1:29,51:550)));shading interp; view(2);
new_data(subjects,:,:,2) = squeeze(WAV.data{1,3}(28,1:29,51:550));
set(gca,'clim',[0 2]);        colormap(colors);
plot_num = plot_num+1;
end

avg_data = squeeze(mean(new_data));
[idx,C] = kmeans((squeeze(avg_data(:,:,1))),10);
k_data(2,:) = kmeans((squeeze(avg_data(:,:,2))),10);

k_results1 = vec2mat(k_data(1,:)',500);
k_results2 = vec2mat(k_data(2,:)',500);