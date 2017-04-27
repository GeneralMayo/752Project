addpath('utils/');
RELEVANT_CHANNELS = [1,4];

folderPath = 'emglogs 2017-29-3/';
fileNames = cell(1,5);
fileNames{1} = 'flexion unitylog 2017-29-3--12-01-51.txt';
fileNames{2} = 'extension unitylog 2017-29-3--12-02-21.txt';
fileNames{3} = 'cocontract unitylog 2017-29-3--12-00-54.txt';
fileNames{4} = 'rest unitylog 2017-29-3--12-00-18.txt';
fileNames{5} = 'spaceinvaders unitylog 2017-29-3--12-04-20.txt';
[training,testing] = get_emg_data(folderPath, fileNames);

thresholdClassifications = testing{1}(:,1);

%combine data for each contraction
trainingCombined = [];
for cIdx = 1:size(training,2)
    trainingCombined = [trainingCombined;training{cIdx}];
end

%fit gmm (4 distributions)
K = 4;

%% look for new clusters if so long as data isn't being separated 
clustersNotUnique = true;
while(clustersNotUnique)
    gm = fitgmdist(trainingCombined(:,RELEVANT_CHANNELS),K);
    
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
