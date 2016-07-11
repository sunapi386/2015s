function ig = importance(data_set, testLabel)
% returns the information gain for each of the attributes (labels)
num_words = size(data_set,2);
% ig = zeros(num_words,1);
p = sum(testLabel==2); % number of twos appearing
n = length(testLabel) - p;
% no gain from no documents
% if n + p == 0
%     ig = 0;
%     return;
% end
% entropy of the goal attribute on the whole set
H = entropy(p / (p + n));
% for every word in the data set, compute that information gain
% for word = 1 : num_words
%     word = word_num;
    rmdr = 0;
    % for every word and each category, calc its part in the remainder of i
    for value = [0,1];
        p_k = 0;
        n_k = 0;
        % compute the number of positive and negative examples
        % for the category cat
        for doc = 1:length(testLabel);
            % if the ex example has the value of labels(j) of the attribute i...
            disp(['r:', num2str(rmdr), ' v:', num2str(value), ' d:', num2str(doc), ' pk:', num2str(p_k), ' nk:', num2str(n_k), ' x ', num2str(data_set(doc,word)), ' v ', num2str(value)]);
%             disp([' v:', num2str(value)]);
%             disp([' d:', num2str(doc)]);
% disp([]);
            if data_set(doc, word) == value
                % ... check its goal attribute value, and add accordingly
                if testLabel(doc) == 2
                    p_k = p_k + 1;
                else
                    n_k = n_k + 1;
                end
            end    
            
        end
        % add the current summation term
        if p_k + n_k ~= 0
            rmdr = rmdr + (((p_k + n_k) / (p + n)) * entropy(p_k / (p_k + n_k)));
        else
            rmdr = rmdr + 0;
        end
    end
    ig = H - rmdr;
    % compute the information gain
%     ig(word) = H - rmdr;
% end
end
