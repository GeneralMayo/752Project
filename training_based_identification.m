close all
clear
clc

addpath('utils/');
[old_training,old_testing] = get_emg_data('emglogs 2017-29-3/spaceinvaders unitylog 2017-29-3--12-04-20.txt');
GMM = 1; % 0: use original labels, 1: use GMM labels

if GMM == 1 % use GMM labels
    unlabeledData = remove_outliers([old_training{1}; old_training{2}; old_training{3}; old_training{4}; old_testing{1}(:,2:end)]);
    gmm = get_GMM_model(unlabeledData(:,[1 4]),4,1000,0.01);
    gmmLabels = manual_cluster(gmm,unlabeledData(:,[1 4]));
    for i = 1:4
        training{i} = unlabeledData(gmmLabels==i,:);
    end
    % NOTE: need to add outliers back into testing dataset???
    testing{1} = [training{1}(end+1-floor(size(training{1},1)/2):end,:); training{2}(end+1-floor(size(training{2},1)/2):end,:); training{3}(end+1-floor(size(training{3},1)/2):end,:); training{4}(end+1-floor(size(training{4},1)/2):end,:)];
    testing{1}(:,2:9) = testing{1};
    testing{1}(:,1) = zeros(size(testing{1},1),1); % just set all labels to 0 since we don't need them
    for i = 1:4
        training{i}(end+1-floor(size(training{i},1)/2):end,:) = [];
    end
else % use original labels
    for i = 1:4
        training{i} = remove_outliers(old_training{i});
    end
    testing = old_testing;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL IDENTIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MLE from derived function
theta1 = size(training{1},1)./sum(training{1},1);
theta2 = size(training{2},1)./sum(training{2},1);
theta3 = size(training{3},1)./sum(training{3},1);
theta4 = size(training{4},1)./sum(training{4},1);

% MLE from MATLAB function
for channel = 1:8
    theta1_check(channel) = mle(training{1}(:,channel),'distribution','exp');
    theta2_check(channel) = mle(training{2}(:,channel),'distribution','exp');
    theta3_check(channel) = mle(training{3}(:,channel),'distribution','exp');
    theta4_check(channel) = mle(training{4}(:,channel),'distribution','exp');
end

% Priors
p1 = size(training{1},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
p2 = size(training{2},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
p3 = size(training{3},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
p4 = size(training{4},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
% p1 = 0.114607449824912;
% p2 = 0.251456247722116;
% p3 = 0.460660654309168;
% p4 = 0.173275648143803;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cluster the data
for k = 1:size(testing{1},1)
    % Using MLE from derived function
    numerator1 = p1*exppdf(testing{1}(k,2),1/theta1(1))*exppdf(testing{1}(k,5),1/theta1(4));
    numerator2 = p2*exppdf(testing{1}(k,2),1/theta2(1))*exppdf(testing{1}(k,5),1/theta2(4));
    numerator3 = p3*exppdf(testing{1}(k,2),1/theta3(1))*exppdf(testing{1}(k,5),1/theta3(4));
    numerator4 = p4*exppdf(testing{1}(k,2),1/theta4(1))*exppdf(testing{1}(k,5),1/theta4(4));
    denominator = numerator1 + numerator2 + numerator3 + numerator4;
    [~,labels(k)] = max([numerator1/denominator numerator2/denominator numerator3/denominator numerator4/denominator]);
    % Using MATLAB MLE
    numerator1_check = p1*exppdf(testing{1}(k,2),theta1_check(1))*exppdf(testing{1}(k,5),theta1_check(4));
    numerator2_check = p2*exppdf(testing{1}(k,2),theta2_check(1))*exppdf(testing{1}(k,5),theta2_check(4));
    numerator3_check = p3*exppdf(testing{1}(k,2),theta3_check(1))*exppdf(testing{1}(k,5),theta3_check(4));
    numerator4_check = p4*exppdf(testing{1}(k,2),theta4_check(1))*exppdf(testing{1}(k,5),theta4_check(4));
    denominator_check = numerator1_check + numerator2_check + numerator3_check + numerator4_check;
    [~,labels_check(k)] = max([numerator1_check/denominator_check numerator2_check/denominator_check numerator3_check/denominator_check numerator4_check/denominator_check]);
end

names{1} = 'relax';
names{2} = 'flexion';
names{3} = 'extention';
names{4} = 'co-contraction';
figure(); % My MLE
hold on
scatter(testing{1}(labels==4,2),testing{1}(labels==4,5),'m');
scatter(testing{1}(labels==1,2),testing{1}(labels==1,5),'r');
scatter(testing{1}(labels==2,2),testing{1}(labels==2,5),'k');
scatter(testing{1}(labels==3,2),testing{1}(labels==3,5),'b');
if GMM == 0
    title('Exponential Classification - Original Labels');
else
    title('Exponential Classification - GMM Labels');
end
xlabel('Channel 1');
ylabel('Channel 4');
legend(names);
hold off
figure(); % MATLAB MLE
hold on
scatter(testing{1}(labels_check==4,2),testing{1}(labels_check==4,5),'m');
scatter(testing{1}(labels_check==1,2),testing{1}(labels_check==1,5),'r');
scatter(testing{1}(labels_check==2,2),testing{1}(labels_check==2,5),'k');
scatter(testing{1}(labels_check==3,2),testing{1}(labels_check==3,5),'b');
if GMM == 0
    title('Exponential Classification - Original Labels');
else
    title('Exponential Classification - GMM Labels');
end
xlabel('Channel 1');
ylabel('Channel 4');
legend(names);
hold off

if GMM == 0
    figure();
    hold on
    scatter(testing{1}(testing{1}(:,1)==4,2),testing{1}(testing{1}(:,1)==4,5),'m');
    scatter(testing{1}(testing{1}(:,1)==1,2),testing{1}(testing{1}(:,1)==1,5),'r');
    scatter(testing{1}(testing{1}(:,1)==2,2),testing{1}(testing{1}(:,1)==2,5),'k');
    scatter(testing{1}(testing{1}(:,1)==3,2),testing{1}(testing{1}(:,1)==3,5),'b');
    title('True Clustering'); % doesn't display correctly if GMM = 1 since all labels are set to 0
    xlabel('Channel 1');
    ylabel('Channel 4');
    legend(names);
    hold off
end