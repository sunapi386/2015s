clear;
clc;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % Load data
load xorData.csv;
load xorLabel.csv;
data = xorData;
label = xorLabel;
% 
% load trainData.csv;
% load trainLabels.csv;
% data = trainData;
% label = trainLabels - min(trainLabels);
% 
% n = 10;
% data = [ones(n,1), [rand(5,n/2); 1 + rand(5,n/2)]];
% label = [zeros(n/2, 1); ones(n/2, 1)];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Threshold Perceptron Learning the weights
weights = zeros(1,size(data,2));
MAX_ITERS = 5000;
for i = 1:MAX_ITERS % limit set arbitrary at 500
    prev = weights;
    weights = percept_threshold(weights,data,label);
%     disp (sum(prev - weights));
%     disp (weights);
    if trained_correctly(weights, data, label);
        disp(['Trained correctly in ', num2str(i), ' iterations']);
        break;
    end
end
if i == MAX_ITERS
    disp(['Unsucessful training in ', num2str(i), ' iterations']);
end
        
disp('Done');

