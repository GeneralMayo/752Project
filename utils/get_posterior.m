function posterior_contractions = get_posterior(gm,data,contraction2cluster,RELEVANT_CHANNELS)

posterior_clusters = posterior(gm,data(:,RELEVANT_CHANNELS));
posterior_contractions = zeros(size(posterior_clusters));

for contraction_idx = 1:4
    posterior_contractions(:,contraction_idx) = posterior_clusters(:,contraction2cluster(contraction_idx));
end

end

