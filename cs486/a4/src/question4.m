% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Question 4. j53sun (#20387090)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Load training data
% Training data contains 753 images 8x8 pixels, giving us 64 input layer
% units, not counting bias node
clear; close all; clc;
load trainData.csv;
load trainLabels.csv;
load testData.csv;
load testLabels.csv;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Initialize
input_layer_size = size(trainData, 2); % 8x8 input image of digit
num_labels = 2;                        % 6 or 7
alpha = 0.001;                         % learning rate
max_iter = 1000;
options = optimset('MaxIter', max_iter);
data = trainData;
tdata = testData;

% Scale the labels
label = trainLabels - min(trainLabels) + 1;
tlabel = testLabels - min(testLabels) + 1;

minNodes = 5;
maxNodes = 15;

% Store results in matrix for graphing
results = zeros(maxNodes - minNodes, 2);

for hidden_layer_size = minNodes:maxNodes     % variable hidden units

% Weights unrolled and initalized to random numbers in [-0.5,0.5]
weightsInputLayer = rand(hidden_layer_size, input_layer_size + 1);
weightsOutputLayer = rand(num_labels, hidden_layer_size + 1);
weightsInital = [weightsInputLayer(:) ; weightsOutputLayer(:)] - 0.5;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Train neural network

fprintf('Training neural network with %d nodes %d iterations\n', ...
    hidden_layer_size, max_iter);

% Create a simplified reference to the cost function to be minimized
cost_fn = @(p) f_nnCostFunction(p, ...
                                input_layer_size,  ...
                                hidden_layer_size, ...
                                num_labels, data, label, alpha);

% Call an optimization library to do descent
[weights, cost] = fmincg(cost_fn, weightsInital, options);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Unroll weights
weightsInput = reshape( ...
         weights(1:hidden_layer_size * (input_layer_size + 1)), ...
         hidden_layer_size, (input_layer_size + 1));

weightsHidden = reshape( ...
         weights(1 + hidden_layer_size * (input_layer_size + 1):end), ...
         num_labels, (hidden_layer_size + 1));


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%  Predict: compute the training set and test set accuracy

predtrain = f_predict(weightsInput, weightsHidden, data);
predtest = f_predict(weightsInput, weightsHidden, tdata);

acc_train = mean(double(predtrain == label)) * 100;
acc_test = mean(double(predtest == tlabel)) * 100;

fprintf('Accuracy (%d hidden nodes) training %f%%, test %f%%\n', ...
    hidden_layer_size, acc_train, acc_test);

results(hidden_layer_size - minNodes + 1, :) = [acc_train, acc_test];
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Plot the graph

creategraph(results);
disp(results);

