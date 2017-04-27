function labels = manual_cluster(gmm,data)
    N = size(data,1);
    priors = gmm{1,1};
    mu = gmm{1,2};
    sigma = gmm{1,3};
    k = size(priors,2);
    
    %get posterior
    P_clusterGdata = zeros(N,k);
    for i = 1:k
        %P(Data_i | k, mu_k, sigma_k)
        P_clusterGdata(:,i) = mvnpdf(data,mu(i,:),sigma{i,1});
    end
    
    for i = 1:N
        %P(Data_i, k | mu_k, sigma_k)
        P_clusterGdata(i,:) = P_clusterGdata(i,:).*priors;
        %P(k | Data_i, mu_k, sigma_k)
        P_clusterGdata(i,:) = P_clusterGdata(i,:)./sum(P_clusterGdata(i,:));
    end
    
    [v,labels] = max(P_clusterGdata,[],2);
end