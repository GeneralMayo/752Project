function [training,testing] = get_emg_data(folderPath, fileNames)
    addpath('utils/');
    %{
        Get testing and training data.
        Input:
            folderPath: str
                String of path to folder containing testing/training data.
                ex: 'emglogs 2017-29-3/'
            fileNames: cell(1,5) of str
                Cell array of file names pertaining to flexion training
                data, extention training data, cocontraction training data
                ,relax training data and testing data (a mix of
                contractions) respectively.
        Returns:
            training: cell(1,4) of matricies
                Each matrix corresponds to flexion training
                data, extention training data, cocontraction training data
                ,relax training data respectively.
            testing: cell(1,1) containing one matrix
                This matrix corresponds to the testing samples (columns
                2:9) and their corresponding labels (column 1).
    %}
    %% Get Raw Training Data
    flexion_raw = dlmread([folderPath,fileNames{1}]);
    extention_raw = dlmread([folderPath,fileNames{2}]);
    coContraction_raw = dlmread([folderPath,fileNames{3}]);
    relax_raw = dlmread([folderPath,fileNames{4}]);

    %% Remove timestamp/labeling/etra MAV value
    flexion = flexion_raw(:,4:end);
    extention = extention_raw(:,4:end);
    coContraction = coContraction_raw(:,4:end);
    relax = relax_raw(:,4:end);

    %% Store Training Data
    training = cell(1,4);
    training{1} = flexion;
    training{2} = extention;
    training{3} = coContraction;
    training{4} = relax;
    
    %% Get Testing Data
    raw_test_data = dlmread([folderPath, fileNames{5}]);
    test_data = get_test_data_labels(raw_test_data,training);
    
    %% Use Half of Testing Rest Data for Training (explanation below)
    new_test_data = [];
    new_relax_data = [];
    rest_count = 0;
    for i = 1:size(test_data,1)
        %rest samples are classified as 4
        if(test_data(i,1)==4 && mod(rest_count,2)==0)
            new_relax_data = [new_relax_data; test_data(i,2:9)];
            rest_count= rest_count+1;
        elseif(test_data(i,1)==4)
            new_test_data = [new_test_data; test_data(i,:)];
            rest_count=rest_count+1;
        else
            new_test_data = [new_test_data; test_data(i,:)];
        end
    end
    
    training{4} = new_relax_data;
    
    testing = cell(1,1);
    testing{1} = new_test_data;
    %Note: rest data in training data set has a significantly different 
    %distributionthan from rest data in testing data set
end

