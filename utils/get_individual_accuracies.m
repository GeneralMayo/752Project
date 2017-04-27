function accuracies = get_individual_accuracies(predictons,labels)
accuracies = zeros(1,4);
for i = 1:4
    accuracies(i) = sum(and((predictons' == i),labels == i))/sum(labels == i);
end
end