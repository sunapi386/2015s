% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Question 3. j53sun (#20387090)
clear;
clc;
load trainData.csv;
load trainLabels.csv;
load testData.csv;
load testLabels.csv;
% Add bias nodes
data = [ones(length(trainLabels),1), trainData];
tdata = [ones(length(testLabels),1), testData];
% Scale the labels to [0,1]
label = trainLabels - min(trainLabels);
tlabel = testLabels - min(testLabels);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Threshold Perceptron: learn the weights
weights = zeros(1,size(data,2));
for i = 1:500 % limit set arbitrary at 500 (it stops earlier)
    weights = percept_threshold(weights,data,label);
    % Keep training until all training data is classified correctly
    if trained_correctly(weights, data, label);
        disp(['Trained correctly in ', num2str(i), ' iterations']);
        break;
    end
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Classify the testing data with the weight vector
predictions = predict_using_weights(weights, tdata, tlabel);
num_correct = sum(predictions == tlabel);
total = length(predictions);
disp(['Correct predictions: ' num2str(100*num_correct/total) '% (' ...
      num2str(num_correct) '/', num2str(total) ')']);
disp(['Final weights: ' num2str(weights)]);
