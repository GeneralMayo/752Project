function gmm = get_GMM_model(dataSeperate,k,max_iter,min_change)


%combine data for each contraction
data = [];
for cIdx = 1:size(dataSeperate,2)
    data = [data; dataSeperate{cIdx}];
end
data = remove_outliers(data);

%% Initialize Parameters of GMM
N = size(data,1);
D = size(data,2);

%init means
mu = zeros(k,D);
for i = 1:k
    mu(i,:) = mean(dataSeperate{i});
end

%init covariance
sigma = cell(k,1);
for i = 1:k
    sigma{i,1} = cov(dataSeperate{i});
end

%init prior
priors = zeros(1,k);
for i = 1:k
    priors(i) = size(dataSeperate{i},1)/N;
end

%% Expectation Maximization
P_clusterGdata = zeros(N,k);
for iter = 1:max_iter
    %E-Step: Calculate P(cluster_k | Data_i) for all clusters + data points
    %1) get P(Data_i | k, mu_k, sigma_k)
    for i = 1:k
        P_clusterGdata(:,i) = mvnpdf(data,mu(i,:),sigma{i,1});
    end
    %2) get posterior
    for i = 1:N
        %P(Data_i, k | mu_k, sigma_k)
        P_clusterGdata(i,:) = P_clusterGdata(i,:).*priors;
        %P(k | Data_i, mu_k, sigma_k)
        P_clusterGdata(i,:) = P_clusterGdata(i,:)./sum(P_clusterGdata(i,:));
    end
    
    %M-Step: maximize priors, mus and simgas
    old_sigma = sigma;
    old_mu = mu;
    old_priors = priors;
    %figure;
    %plot(mu(1,1),mu(1,2),mu(2,1),mu(2,2),mu(3,1),mu(3,2),mu(4,1),mu(4,2))
    for cluster_idx = 1:k
        %commonly used var
        sum_posterior = sum(P_clusterGdata(:,cluster_idx));
        
        %update prior
        priors(cluster_idx) = sum_posterior/N;
        
        %update mean
        for j = 1:D
            mu(cluster_idx,j) = sum(P_clusterGdata(:,cluster_idx).*data(:,j))/sum_posterior;
        end
        
        %update sigma
        s_k = zeros(D,D);
        for j = 1:N
            s_k = s_k + P_clusterGdata(j,cluster_idx)*(data(j,:)-mu(cluster_idx,:))'*(data(j,:)-mu(cluster_idx,:));
        end
        sigma{cluster_idx,1} = s_k/sum_posterior;
    end
    
    if(has_conveged(old_priors,old_sigma,old_mu,priors,sigma,mu, min_change))
        break;
    end
end
gmm = cell(1,3);
gmm{1,1} = priors;
gmm{1,2} = mu;
gmm{1,3} = sigma;
end
