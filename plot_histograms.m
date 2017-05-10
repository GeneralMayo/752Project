clear;
clc;

addpath('utils/');

fileName = 'emglogs 2017-29-3/spaceinvaders unitylog 2017-29-3--12-04-20.txt';
%fileName = 'SpaceInvaders_unitylog_2017419T143810.txt';


RELEVANT_CHANNELS = [1,2,3,4,5,6,7,8];
numCh = size(RELEVANT_CHANNELS,2);
numContractions = 4;

chNames = cell(1,8);
for i = 1:8
    chNames{i} = ['Ch_',num2str(i)];
end

contractionNames = cell(1,4);
contractionNames{1} = 'Flexion';
contractionNames{2} = 'Extention';
contractionNames{3} = 'Cocontraction';
contractionNames{4} = 'Rest';


[training, testing] = get_emg_data(fileName);



for i = 1:numContractions
    for j = 1:numCh
        subplot(numContractions,numCh,(i-1)*numCh+j)
        histogram(training{i}(:,j),linspace(0,4,20))
        title([chNames{j},' ',contractionNames{i}])
        %xlabel('EMG MAV')
    end
end
