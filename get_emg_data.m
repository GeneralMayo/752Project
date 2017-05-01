function [training,testing] = get_emg_data(filePath)
    addpath('utils/');
    %{
        Get testing and training data.
        Input:
            filePath: str
                Path to a file containing unity log data of a game.
        Returns:
            training: cell(1,4) of matricies
                Each matrix corresponds to flexion training
                data, extention training data, cocontraction training data
                ,relax training data respectively.
            testing: cell(1,1) containing one matrix
                This matrix corresponds to the testing samples (columns
                2:9) and their corresponding labels (column 1).
    %}
    
    %% Get Data + Add Better Labels + Strip Off Useless Features
    data=load(filePath);
    %data = dlmread(filePath);
    data = add_data_labels(data);

    
    %% Use every other sample type for training/testing data set
    new_test_data = [];
    new_relax_data = [];
    new_flex_data = [];
    new_ext_data = [];
    new_cc_data = [];
    rest_count = 0;
    flex_count = 0;
    ext_count = 0;
    cc_count = 0;
    for i = 1:size(data,1)
        %rest samples are classified as 4
        if(data(i,1)==4 && mod(rest_count,2)==0)
            new_relax_data = [new_relax_data; data(i,2:9)];
            rest_count= rest_count+1;
        elseif(data(i,1)==4 && mod(rest_count,2)==1)
            new_test_data = [new_test_data; data(i,:)];
            rest_count=rest_count+1;
        elseif(data(i,1)==1 && mod(flex_count,2)==0)
            new_flex_data = [new_flex_data; data(i,2:9)];
            flex_count= flex_count+1;
        elseif(data(i,1)==1 && mod(flex_count,2)==1)
            new_test_data = [new_test_data; data(i,:)];
            flex_count=flex_count+1;
        elseif(data(i,1)==2 && mod(ext_count,2)==0)
            new_ext_data = [new_ext_data; data(i,2:9)];
            ext_count= ext_count+1;
        elseif(data(i,1)==2 && mod(ext_count,2)==1)
            new_test_data = [new_test_data; data(i,:)];
            ext_count=ext_count+1;
        elseif(data(i,1)==3 && mod(cc_count,2)==0)
            new_cc_data = [new_cc_data; data(i,2:9)];
            cc_count= cc_count+1;
        elseif(data(i,1)==3 && mod(cc_count,2)==1)
            new_test_data = [new_test_data; data(i,:)];
            cc_count=cc_count+1;
        end
    end
    
    training{4} = new_relax_data;
    training{1} = new_flex_data;
    training{2} = new_ext_data;
    training{3} = new_cc_data;
    
    testing = cell(1,1);
    testing{1} = new_test_data;
end

