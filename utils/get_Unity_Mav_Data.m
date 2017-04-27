function data = get_Unity_Mav_Data(raw_data)
    relaxCode = 0;
    flexionCode = [4,6];
    extensionCode = [5,7];
    cocontractionCode = 101;
    
    contractionCodes = raw_data(:,2);
    chanMAVData = raw_data(:,4:end);
    
    flexionCluster = chanMAVData(contractionCodes==flexionCode(1),:);
    flexionCluster = [flexionCluster ; chanMAVData(contractionCodes==flexionCode(2),:)];
    extensionCluster = chanMAVData(contractionCodes==extensionCode(1),:);
    extensionCluster = [extensionCluster ; chanMAVData(contractionCodes==extensionCode(2),:)];
    cocontractionCluster = chanMAVData(contractionCodes==cocontractionCode,:);
    relaxCluster = chanMAVData(contractionCodes==relaxCode,:);
      
    data = cell(1,4);
    
    data{1} = flexionCluster;
    data{2} = extensionCluster;
    data{3} = cocontractionCluster;
    data{4} = relaxCluster;
end