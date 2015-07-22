clear;
clc;

load trainData.csv;
load trainLabels.csv;
data = trainData;
label = trainLabels - min(trainLabels);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Threshold Perceptron Learning the weights
weights = zeros(1,size(data,2));
for i = 1:500 % limit set arbitrary at 500
    prev = weights;
    weights = percept_threshold(weights,data,label);
    if trained_correctly(weights, data, label);
        disp(['Trained correctly in ', num2str(i), ' iterations']);
        break;
    end
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Classify the testing examples with this weight vector
load testData.csv;
load testLabels.csv;
tdata = testData;
tlabel = testLabels - min(testLabels);
result = predict_using_weights(weights, tdata, tlabel);
disp(['Predicted ', num2str(sum(result)), '/', num2str(length(result)) ...
      ' ', num2str(100*sum(result)/length(result)), '%']);
