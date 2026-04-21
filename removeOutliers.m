%% This function replaces data points which |zscores| exceeds 3 by NaNs
%
% Input variables:
% -Data: data point (matrix of size = number of participants * number of experiemtnal conditions)
%
% Output variables:
% -Data: data point (matrix of size = number of participants * number of experiemtnal conditions)
%
% C. Ziane

function[Data] = removeOutliers(Data)

% Preallocate vector
Z = nan(size(Data,1),size(Data,2));

% Repeat zscore calculation and outlier identification for each condition
for iCol = 1:size(Data,2)
    dataCol = Data(:,iCol);
    Z(~isnan(dataCol),iCol) = zscore(dataCol(~isnan(dataCol)));
    Outliers(:,iCol) = abs(Z(:,iCol)) >= 3;
end

% Replace outliers with nan
Data(Outliers == 1) = nan;

end