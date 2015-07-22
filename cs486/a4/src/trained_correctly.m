function [ output ] = trained_correctly( weights, data, label )
%F_TRAINED_CORRECTLY Returns 1 if all correct, 0 else.
for i = 1 : length(data)
    if label(i) ~= f_step(weights * data(i,:)')
        output = 0;
        return;
    end
end
output = 1;
return;
end
