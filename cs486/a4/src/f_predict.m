function p = f_predict(Theta1, Theta2, X)
%F_PREDICT Predict the label of an input given a trained neural network
m = size(X, 1);
h1 = f_sigmoid([ones(m, 1) X] * Theta1');
h2 = f_sigmoid([ones(m, 1) h1] * Theta2');
[~, p] = max(h2, [], 2);
end
