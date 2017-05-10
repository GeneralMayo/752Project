clear;
clc;

addpath('utils/');

fileName = 'emglogs 2017-29-3/spaceinvaders unitylog 2017-29-3--12-04-20.txt';
%fileName = 'SpaceInvaders_unitylog_2017419T143810.txt';

RELEVANT_CHANNELS = [1,2,3,4,5,6,7,8];

[training, testing] = get_emg_data(fileName);
displayClassifications(testing{1}(:,2:end),testing{1}(:,1),'Manual Labels',RELEVANT_CHANNELS)

%feature reduction
trainingNewD = cell(1,size(training,2));
for i = 1:length(training)
    trainingNewD{i} = training{i}(:,RELEVANT_CHANNELS);
end
%fit gmm (4 distributions)
K = 4;

data = [];
for cIdx = 1:size(training,2)
    data = [data; training{cIdx}];
end

gmm = get_GMM_model(trainingNewD,K,1000,.01);

testSamples = testing{1}(:,2:end);
P_clusterGdata = get_posterior_project(gmm,testSamples(:,RELEVANT_CHANNELS));%testing{1}(:,RELEVANT_CHANNELS));

disp(cov(P_clusterGdata))
keyboard;

[v,labels] = max(P_clusterGdata,[],2);
displayClassifications(testSamples,labels,'GMM Classification',RELEVANT_CHANNELS)

display_posterior_vs_channel(testSamples,P_clusterGdata,4,[1,3]);






%{
%% look for new clusters if so long as data isn't being separated 
clustersNotUnique = true;
while(clustersNotUnique)
    gmm = get_GMM_model(trainingCombined(:,RELEVANT_CHANNELS),K,1000,.01);
    
    %get frequency of particular contractions being assigned to
    %particular clusters
    labelFreq = zeros(K,K);
    trainingClusters = cell(1,4);
    for contractionIdx=1:size(training,2)   
        labels = cluster(gm,training{contractionIdx}(:,RELEVANT_CHANNELS));
        for label = 1:K
           labelFreq(contractionIdx,label) = sum(labels==label);
        end
        
        trainingClusters{contractionIdx} = labels;
    end
    
    [mv,I] = max(labelFreq');
    if(length(unique(I))==K)
        clustersNotUnique = false;
    end
end

%% map contraction # to cluster #
[mv,contractionIdx2Cluster] = max(labelFreq');

%% map cluster # to contraction #
cluster2ContractionIdx = zeros(1,4);
cluster2ContractionIdx(contractionIdx2Cluster(1)) = 1;
cluster2ContractionIdx(contractionIdx2Cluster(2)) = 2;
cluster2ContractionIdx(contractionIdx2Cluster(3)) = 3;
cluster2ContractionIdx(contractionIdx2Cluster(4)) = 4;



%% display training classifications
trainingPredictions = [];
trainingData = [];
for contractionIdx = 1:4
    for cLIdx = 1:length(trainingClusters{contractionIdx})
        trainingPredictions = [trainingPredictions; cluster2ContractionIdx(trainingClusters{contractionIdx}(cLIdx))];
        trainingData = [trainingData; training{contractionIdx}(cLIdx,:)];
    end
end
%displayClassifications(trainingData,trainingPredictions,'GMM Training',RELEVANT_CHANNELS);

%% display testing classifications
testingPredictions = gmm_predict(gm, testing{1}(:,2:end), cluster2ContractionIdx, RELEVANT_CHANNELS);
displayClassifications(testing{1}(:,2:end),testingPredictions,'GMM Training',RELEVANT_CHANNELS);

%% Get Training Accuracy
trainingLabels = [];
for i = 1:4
    trainingLabels = [trainingLabels; ones(size(training{i},1),1)*i];
end
disp('Training Accuracy')
disp(sum(trainingLabels==trainingPredictions)/length(trainingPredictions));

%% Get Testing Accuracy
disp('Testing Accuracy')
%overall test accuracy
disp(sum(testing{1}(:,1)==testingPredictions')/length(testingPredictions));
disp('Testing Accuracy Individual Contraction')
%accuracy for each contraction
disp(get_individual_accuracies(testingPredictions,testing{1}(:,1)));


%% Display Aposterior Probabiltis
testSamples = testing{1}(:,2:end);
posterior_contractions = get_posterior(gm,testSamples,contractionIdx2Cluster,RELEVANT_CHANNELS);
disp(size(posterior_contractions))
display_posterior_vs_channel(testSamples,posterior_contractions,4,[1,3]);

%% Display Clusters
[m,classifications] = max(posterior_contractions');
displayClassifications(testSamples,classifications,'GMM Classification',RELEVANT_CHANNELS)
displayClassifications(testSamples,thresholdClassifications,'Manual Threshold Classification',RELEVANT_CHANNELS)
%}