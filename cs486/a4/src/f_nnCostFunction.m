function [J, grad] = f_nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%F_NNCOSTFUNCTION returns the cost and gradient of the neural network

% Unroll weights
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));
Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
m = size(X, 1);

% Feedforward the neural network and return the cost in J
a1 = [ones(m,1) X];
z2 = Theta1*a1';
a2 = [ones(1, m); f_sigmoid(z2)];
z3 = Theta2*a2;
a3 = f_sigmoid(z3);

% Predictions
K = num_labels;
Y = zeros(K, m);
for i = 1:m
    Y(y(i), i) = 1;
end

% Cost function can be replaced to use mean sequared error later
costPos = -Y .* log(a3) ; % result in [1,753]
costNeg = -(1-Y) .* log(1-a3); % result in [1, 753]
cost = costPos + costNeg;
J = (1/m) * sum(cost(:)); % result in [1,1]

% Regularization
Theta1Filtered = Theta1(:,2:end); % result [5, 64]
Theta2Filtered = Theta2(:,2:end); % result [1, 5]
reg = lambda / (2*m) * ( sum( Theta1Filtered(:).^2 ) + sum( Theta2Filtered(:).^2) );
J = J + reg;


% Backpropagation, computing the gradients
Delta1 = 0;
Delta2 = 0;

for t = 1:m
    % Step 1 - Forward propagation: z_i and a_i
    a1 = [1 X(t,:)]';
    z2 = Theta1 * a1;
    a2 = [1; f_sigmoid(z2)];
    z3 = Theta2 * a2;
    a3 = f_sigmoid(z3);

    % Step 2a - Error calculations: output layer
    yt = Y(:,t);
    d3 = a3 - yt;

    % Step 2b - Error calculations: hidden layers
    d2 = Theta2Filtered' * d3 .* f_sigmoidGradient(z2);

    % Step 3a - Gradient calculation using a_i and the error d_i
    Delta2 = Delta2 + d3 * a2';
    Delta1 = Delta1 + d2 * a1';
end
Theta1_grad = (1/m) * Delta1;
Theta2_grad = (1/m) * Delta2;


% Regularization with the cost function and gradients
Theta1_grad(:,2:end) = Theta1_grad(:,2:end) + ((lambda/m) * Theta1Filtered);
Theta2_grad(:,2:end) = Theta2_grad(:,2:end) + ((lambda/m) * Theta2Filtered);

% Roll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
