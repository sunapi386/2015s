function [corrects] = predict_using_weights(weights, tdata, tlabel)
%PREDICT_USING_WEIGHTS 
predictions = zeros(size(tlabel));
for i = 1 : length(tdata)
    predictions(i) = f_step(weights * tdata(i,:)');
end
corrects = predictions == tlabel;
end
