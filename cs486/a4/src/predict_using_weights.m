function [predictions] = predict_using_weights(weights, tdata, tlabel)
% F_PREDICT_USING_WEIGHTS returns predictions on data given weight.
predictions = zeros(size(tlabel));
for i = 1 : length(tdata)
    predictions(i) = f_step(weights * tdata(i,:)');
end
end
