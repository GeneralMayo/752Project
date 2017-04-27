function displayClassifications(data,classifications,display_title,RELEVANT_CHANNELS)

%init label cluster data structure
labelClusters = cell(1,4);
for i = 1:length(labelClusters)
    labelClusters{i} = [];
end

for cIdx = 1:length(classifications)
    label = classifications(cIdx);
    labelClusters{label} = [labelClusters{label}; data(cIdx,:)];
end

figure;
hold on;
scatter(labelClusters{4}(:,RELEVANT_CHANNELS(1)),labelClusters{4}(:,RELEVANT_CHANNELS(2)),'m');
scatter(labelClusters{1}(:,RELEVANT_CHANNELS(1)),labelClusters{1}(:,RELEVANT_CHANNELS(2)),'r');
scatter(labelClusters{2}(:,RELEVANT_CHANNELS(1)),labelClusters{2}(:,RELEVANT_CHANNELS(2)),'k');
scatter(labelClusters{3}(:,RELEVANT_CHANNELS(1)),labelClusters{3}(:,RELEVANT_CHANNELS(2)),'b');
names = cell(1,4);
names{1} = 'relax';
names{2} = 'flexion';
names{3} = 'extention';
names{4} = 'co-Contraction';
legend(names)

xlabel('Channel 1')
ylabel('Channel 4')
title(display_title)
end

