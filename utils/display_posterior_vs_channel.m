function display_posterior_vs_channel(data,posterior_contractions,chosen_channel,chosen_posteriors)
numSamples = length(data(:,1));

d_percents = zeros(numSamples,length(chosen_posteriors));
for i = 1:length(chosen_posteriors)
    d_percents(:,i) = posterior_contractions(:,chosen_posteriors(i))./sum(posterior_contractions,2);
end

for i = 1:length(chosen_posteriors)
    d_percents(:,i) = tsmovavg(d_percents(:,i)','s',5)';
end

figure;
colors = ['b','r','k'];
plot(1:numSamples,data(:,chosen_channel),colors(1));
hold on
hs = [];
for i = 1:length(chosen_posteriors)
    
    
    %hs = [hs; area(1:numSamples,d_percents(:,i))];
    hs = [hs; plot(1:numSamples,d_percents(:,i),colors(i+1))];
end
%hs(1,1).FaceColor = [1 0 0];
%hs(2,1).FaceColor = [0 0 1];
set(hs(1,1),'linewidth',2);
set(hs(2,1),'linewidth',2);
title('GMM Posterior/ Ch 4 Mav Over Time')
xlabel('Sample')
ylabel('ch 4 MAV/ Posterior')
hL = legend('ch 4 MAV','P(Flexion | sample)','P(Cocontraction | sample)');
set(hL,'FontSize',16);

%ylabel('Posterior Ratio (%)')
%legend('flexion','extention')
