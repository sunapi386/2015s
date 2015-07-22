function [ output ] = f_step( input )
%F_STEP Step-wise activation function
%   Given a list of numbers, return 1 if input >= 0, otherwise 0.
output = input >= 0;
end
