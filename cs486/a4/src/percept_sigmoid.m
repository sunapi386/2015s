function [ weights ] = percept_sigmoid(alpha, weights, data, label)
%PERCEPT Threshold perceptron
    
for i = 1:length(label)
    x = data(i,:);
    y = label(i,:);
    z = weights * x';
    sig = f_sigmoid(z)*(1 - f_sigmoid(z));
    weights = weights + alpha * (y - f_sigmoid(z)) * sig * x;
end

end
