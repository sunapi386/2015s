function [ weights ] = percept(weights, data, label)
%PERCEPT Threshold perceptron
    
for i = 1:length(label)
    x = data(i,:);
    y = label(i,:);
    a = f_step(weights * x'); % step-wise activation
    weights = weights + (y - a) * x;
end

end
