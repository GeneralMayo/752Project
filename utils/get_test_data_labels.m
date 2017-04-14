function labeled_data = get_test_data_labels(raw_test_data,training_data)
    %% Get Raw Game Data
    chanMAVData = raw_test_data(:,4:end);
    
    %% Classify Game Data Using Custom Threshold As Ground Truth
    %Channels where thresholds are compared against
    RELEVANT_CHANNELS = [4,1];
    %Note: Flexion is 25% of channel 4. Extension is 30% of channel 1.
    THRESHOLDS_FE = [.25,.3];
    %Note: Co-contraction is 20% of channel 4 and 1
    THRESHOLDS_CC = [.2,.2];
    
    %get proxy max MAVs for two channels indicated in RELEVANT_CHANNELS
    maxMavs = get_proxy_max_MAV(training_data, RELEVANT_CHANNELS);
    
    %get relevant channels
    cA = chanMAVData(:,RELEVANT_CHANNELS(1));
    cB = chanMAVData(:,RELEVANT_CHANNELS(2));
    
    %above flexion/extention thresholds
    aboveT1 = cA/maxMavs(1) > THRESHOLDS_FE(1);
    aboveT2 = cB/maxMavs(2) > THRESHOLDS_FE(2);
    %above co-contraction thresholds
    aboveT1_CC = cA/maxMavs(1) > THRESHOLDS_CC(1);
    aboveT2_CC = cB/maxMavs(2) > THRESHOLDS_CC(2);
    %not extention or fexion
    notEorF = and(not(and(aboveT1,not(aboveT2))),not(and(not(aboveT1),aboveT2)));
    
    %classify emg samples
    classifications = zeros(length(cA),1);
    for sampleIdx = 1:length(cA)
        if(aboveT1(sampleIdx) && not(aboveT2(sampleIdx)))
            classifications(sampleIdx) = 1;
        elseif(not(aboveT1(sampleIdx)) && aboveT2(sampleIdx))
            classifications(sampleIdx) = 2;
        elseif(aboveT1_CC(sampleIdx) && aboveT2_CC(sampleIdx) && notEorF(sampleIdx))
            classifications(sampleIdx) = 3;
        else
            classifications(sampleIdx) = 4;
        end
    end
    
    %% Return Labeled Data
    labeled_data = [classifications,chanMAVData];
end