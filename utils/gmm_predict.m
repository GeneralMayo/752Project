function labels = gmm_predict(gm,data,cluster2ContractionIdx,RELEVANT_CHANNELS)
    testingClusters = cluster(gm,data(:,RELEVANT_CHANNELS));
    labels = zeros(1,length(testingClusters));
    for i = 1:size(data,1)
        labels(i) = cluster2ContractionIdx(testingClusters(i));
    end
end