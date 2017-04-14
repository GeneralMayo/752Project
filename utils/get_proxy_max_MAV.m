function maxMavs = get_proxy_max_MAV(data,channels)
    maxMavEachContraction = zeros(size(data,2),size(channels,2));
    
    %get max mavs for Flexion, Extention, relax
    for contractionIdx = 1:size(data,2)
        for chanIdx = 1:size(channels,2)
            channelData = data{contractionIdx}(:,channels(chanIdx));
            maxMavEachContraction(contractionIdx,chanIdx) = max(channelData);
        end
    end
    
    maxMavs = max(maxMavEachContraction);
end

