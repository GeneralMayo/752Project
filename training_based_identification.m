close all
clear
clc

addpath('utils/');
fileName = 'data/spaceInvaders1.txt';
%fileName = 'data/spaceInvaders2.txt';

[old_training,old_testing] = get_emg_data(fileName);
GMM = 1; % 0: use CAPS labels, 1: use GMM labels
channels14 = 1; % 1: use only channels 1 & 4; 0: use all channels

if GMM == 1 % use GMM labels
    for i = 1:length(old_training)
        trainingNewD{i} = old_training{i}(:,[1 4]);
    end
    gmm = get_GMM_model(trainingNewD,4,1000,0.01);
    unlabeledData = [old_training{1}; old_training{2}; old_training{3}; old_training{4}; old_testing{1}(:,2:end)];
    P_clusterGdata = get_posterior_project(gmm,unlabeledData(:,[1 4]));
    [~,gmmLabels] = max(P_clusterGdata,[],2);
    for i = 1:4
        training{i} = unlabeledData(gmmLabels==i,:);
    end
    testing{1} = [ones(floor(size(training{1},1)/2),1) training{1}(end+1-floor(size(training{1},1)/2):end,:); 2*ones(floor(size(training{2},1)/2),1) training{2}(end+1-floor(size(training{2},1)/2):end,:); 3*ones(floor(size(training{3},1)/2),1) training{3}(end+1-floor(size(training{3},1)/2):end,:); 4*ones(floor(size(training{4},1)/2),1) training{4}(end+1-floor(size(training{4},1)/2):end,:)];
    for i = 1:4
        training{i}(end+1-floor(size(training{i},1)/2):end,:) = [];
    end
    training{i} = remove_outliers(training{i});
else % use CAPS labels
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

% % MLE from MATLAB function
% for channel = 1:8
%     theta1_check(channel) = mle(training{1}(:,channel),'distribution','exp');
%     theta2_check(channel) = mle(training{2}(:,channel),'distribution','exp');
%     theta3_check(channel) = mle(training{3}(:,channel),'distribution','exp');
%     theta4_check(channel) = mle(training{4}(:,channel),'distribution','exp');
% end

% Priors
p1 = size(training{1},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
p2 = size(training{2},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
p3 = size(training{3},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
p4 = size(training{4},1)/(size(training{1},1)+size(training{2},1)+size(training{3},1)+size(training{4},1));
% p1 = 0.131301126875506;
% p2 = 0.105030645737078;
% p3 = 0.239933242119802;
% p4 = 0.523734985267613;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cluster the data
for k = 1:size(testing{1},1)
    % Using MLE from derived function
    if channels14 == 1
        numerator1 = p1*exppdf(testing{1}(k,2),1/theta1(1))*exppdf(testing{1}(k,5),1/theta1(4));
        numerator2 = p2*exppdf(testing{1}(k,2),1/theta2(1))*exppdf(testing{1}(k,5),1/theta2(4));
        numerator3 = p3*exppdf(testing{1}(k,2),1/theta3(1))*exppdf(testing{1}(k,5),1/theta3(4));
        numerator4 = p4*exppdf(testing{1}(k,2),1/theta4(1))*exppdf(testing{1}(k,5),1/theta4(4));
    else
        numerator1 = p1;
        numerator2 = p2;
        numerator3 = p3;
        numerator4 = p4;
        for i = 1:8
            numerator1 = numerator1*exppdf(testing{1}(k,i+1),1/theta1(i));
            numerator2 = numerator2*exppdf(testing{1}(k,i+1),1/theta2(i));
            numerator3 = numerator3*exppdf(testing{1}(k,i+1),1/theta3(i));
            numerator4 = numerator4*exppdf(testing{1}(k,i+1),1/theta4(i));
        end
    end
    denominator = numerator1 + numerator2 + numerator3 + numerator4;
    [~,labels(k)] = max([numerator1/denominator numerator2/denominator numerator3/denominator numerator4/denominator]);
    P_clusterGdata2(k,:) = [numerator1/denominator numerator2/denominator numerator3/denominator numerator4/denominator];
%     % Using MATLAB MLE
%     if channels14 == 1
%         numerator1_check = p1*exppdf(testing{1}(k,2),theta1_check(1))*exppdf(testing{1}(k,5),theta1_check(4));
%         numerator2_check = p2*exppdf(testing{1}(k,2),theta2_check(1))*exppdf(testing{1}(k,5),theta2_check(4));
%         numerator3_check = p3*exppdf(testing{1}(k,2),theta3_check(1))*exppdf(testing{1}(k,5),theta3_check(4));
%         numerator4_check = p4*exppdf(testing{1}(k,2),theta4_check(1))*exppdf(testing{1}(k,5),theta4_check(4));
%     else
%         numerator1_check = p1;
%         numerator2_check = p2;
%         numerator3_check = p3;
%         numerator4_check = p4;
%         for i = 1:8
%             numerator1_check = numerator1_check*exppdf(testing{1}(k,i+1),theta1_check(i));
%             numerator2_check = numerator2_check*exppdf(testing{1}(k,i+1),theta2_check(i));
%             numerator3_check = numerator3_check*exppdf(testing{1}(k,i+1),theta3_check(i));
%             numerator4_check = numerator4_check*exppdf(testing{1}(k,i+1),theta4_check(i));
%         end
%     end
%     denominator_check = numerator1_check + numerator2_check + numerator3_check + numerator4_check;
%     [~,labels_check(k)] = max([numerator1_check/denominator_check numerator2_check/denominator_check numerator3_check/denominator_check numerator4_check/denominator_check]);
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
    title('Exponential Classification - Trained with CAPS Labels');
else
    title('Exponential Classification - Trained with GMM Labels');
end
xlabel('Channel 1');
ylabel('Channel 4');
legend(names);
hold off
% figure(); % MATLAB MLE
% hold on
% scatter(testing{1}(labels_check==4,2),testing{1}(labels_check==4,5),'m');
% scatter(testing{1}(labels_check==1,2),testing{1}(labels_check==1,5),'r');
% scatter(testing{1}(labels_check==2,2),testing{1}(labels_check==2,5),'k');
% scatter(testing{1}(labels_check==3,2),testing{1}(labels_check==3,5),'b');
% if GMM == 0
%     title('Exponential Classification - Original Labels');
% else
%     title('Exponential Classification - GMM Labels');
% end
% xlabel('Channel 1');
% ylabel('Channel 4');
% legend(names);
% hold off

figure();
hold on
scatter(testing{1}(testing{1}(:,1)==4,2),testing{1}(testing{1}(:,1)==4,5),'m');
scatter(testing{1}(testing{1}(:,1)==1,2),testing{1}(testing{1}(:,1)==1,5),'r');
scatter(testing{1}(testing{1}(:,1)==2,2),testing{1}(testing{1}(:,1)==2,5),'k');
scatter(testing{1}(testing{1}(:,1)==3,2),testing{1}(testing{1}(:,1)==3,5),'b');
if GMM == 0
    title('CAPS Labels Classification');
else
    title('GMM Labels Classification');
end
xlabel('Channel 1');
ylabel('Channel 4');
legend(names);
hold off

display_posterior_vs_channel(testing{1}(:,2:end),P_clusterGdata2,4,[1,3]);

accuracy = sum(testing{1}(:,1)==labels')/length(labels')