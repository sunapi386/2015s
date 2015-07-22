function [ weights ] = percept(weights, data, label)
%PERCEPT Threshold perceptron
for i = 1:length(label)
    x = data(i,:);
    y = label(i,:);
    a = (weights .* x) >= 0; % step-wise activation
    weights = weights + (y - a) .* x;
    disp(weights);
end
end

