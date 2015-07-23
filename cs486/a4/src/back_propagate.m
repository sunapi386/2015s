function [weights] = back_propagate(weights, data, label)
%F_BACK_PROPAGATE returns updated weights based all instances in data set

weights = f_sigmoid(sum(weights));
end