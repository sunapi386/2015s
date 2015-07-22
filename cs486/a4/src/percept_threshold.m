function [ weights ] = percept_threshold(weights, data, label)
%PERCEPT Threshold perceptron
    
for i = 1:length(label)
    x = data(i,:);
    y = label(i,:);
%     a = f_sigmoid(weights * x'); % step-wise activation
    a = f_step(weights * x'); % step-wise activation
    weights = weights + (y - a) * x;
end

end
