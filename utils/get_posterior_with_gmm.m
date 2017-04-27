function PclusterGdata = get_posterior_with_gmm(filePath)
    RELEVANT_CHANNELS = [1,4];
    
    [training,testing] = get_emg_data(filePath);
    
    %combine data for each contraction
    trainingCombined = [];
    for cIdx = 1:size(training,2)
        trainingCombined = [trainingCombined; training{cIdx}];
    end
    
    %remove outliers
    trainingCombined = remove_outliers(trainingCombined);

    %fit gmm (4 distributions)
    K = 4;
    
    %% look for new clusters so long as clusters arn't being found correctly 
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

        [mv,contractionIdx2Cluster] = max(labelFreq');
        if(length(unique(contractionIdx2Cluster))==K)
            clustersNotUnique = false;
        end
    end
    
    testSamples = testing{1}(:,2:end);
    PclusterGdata = get_posterior(gm,testSamples,contractionIdx2Cluster,RELEVANT_CHANNELS);
end