clear;
clc;

addpath('utils/');

fileName = 'data/spaceInvaders1.txt';
%fileName = 'data/spaceInvaders2.txt';

%only channels 1/4 were observed to be usefult for GMM
RELEVANT_CHANNELS = [1,4];

[training, testing] = get_emg_data(fileName);
displayClassifications(testing{1}(:,2:end),testing{1}(:,1),'Manual Labels',RELEVANT_CHANNELS)

%feature reduction 
trainingNewD = cell(1,size(training,2));
for i = 1:length(training)
    trainingNewD{i} = training{i}(:,RELEVANT_CHANNELS);
end

%fit gmm (4 Guassians)
K = 4;
gmm = get_GMM_model(trainingNewD,K,1000,.01);

%Get Posterior Probabilities
testSamples = testing{1}(:,2:end);
P_clusterGdata = get_posterior_project(gmm,testSamples(:,RELEVANT_CHANNELS));

%MAP Detector
[v,labels] = max(P_clusterGdata,[],2);
displayClassifications(testSamples,labels,'GMM Classification',RELEVANT_CHANNELS)

%Display Posterior Probabilities overlaid on Ch 4 EMG Signal
display_posterior_vs_channel(testSamples,P_clusterGdata,4,[1,3]);