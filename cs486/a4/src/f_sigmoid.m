function [ output ] = f_sigmoid( input )
%F_SIGMOID Sigmoid activation function
output = 1./(1 + exp(-input));
end
