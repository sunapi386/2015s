function g = f_sigmoidGradient(z)
%F_SIGMOIDGRADIENT returns the gradient of sigmoid function at z
g = f_sigmoid(z) .* (1 - f_sigmoid(z));
end
