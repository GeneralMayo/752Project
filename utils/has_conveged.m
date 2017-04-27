function converged = has_conveged(old_priors,old_sigma,old_mu,new_priors,new_sigma,new_mu, min_change)
    converged = true;
    if(sum(abs(old_priors-new_priors)< min_change) ~= size(old_priors,2))
        converged = false;
    end
    
    for i = 1:size(old_sigma,1)
        if(sum(sum(abs(old_sigma{i,1}-new_sigma{i,1})<min_change)) ~= size(old_sigma{i,1},1)*size(old_sigma{i,1},2))
            converged = false;
        end
    end
    
    if(sum(sum(abs(old_mu-new_mu)<min_change)) ~= size(old_mu,1)*size(old_mu,2))
        converged = false;
    end
end

