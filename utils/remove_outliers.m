function data_new = remove_outliers(data)
    I = and(data(:,1)<3,data(:,2)<3);
    data_new = data(I,:);
end

