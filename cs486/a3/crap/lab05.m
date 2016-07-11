function lab05()
% executes the exercise

data_set = load('HAISS2011.txt');
% function decision_tree_learning(examples, depth, attributes, path, parent_examples)
decision_tree_learning(data_set, 0, (1:(size(data_set,2)-1))', [], data_set);
decision_tree_learning(trainData, 0, (1:(size(trainData,2)-1))', [], trainData);

end
