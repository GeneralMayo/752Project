folderPath = 'emglogs 2017-29-3/';
fileNames = cell(1,5);
fileNames{1} = 'flexion unitylog 2017-29-3--12-01-51.txt';
fileNames{2} = 'extension unitylog 2017-29-3--12-02-21.txt';
fileNames{3} = 'cocontract unitylog 2017-29-3--12-00-54.txt';
fileNames{4} = 'rest unitylog 2017-29-3--12-00-18.txt';
fileNames{5} = 'spaceinvaders unitylog 2017-29-3--12-04-20.txt';
[training,testing] = get_emg_data(folderPath, fileNames);
%Note: 
%1st col of cell 1 of testing data are labels
%2nd-9th cols of cell 1 of testing data are "features" corresponding to that label 
RELEVANT_CHANNELS = [1,4];
displayClassifications(testing{1}(:,2:9),testing{1}(:,1),'Testing Data',RELEVANT_CHANNELS);

training_labels = [];
training_data = [];
for contractionType = 1:4
    training_data = [training_data; training{contractionType}];
    training_labels = [training_labels; ones(size(training{contractionType},1),1)*contractionType];
end
displayClassifications(training_data,training_labels,'Training Data',RELEVANT_CHANNELS);