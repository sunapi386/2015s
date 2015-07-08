loadScript
[log_doc1, log_doc2, log_likelihood] = naive_bayes_net(trainDataSparse, trainLabel);

% list the N most discrimative word features
[sortedVals, sortedIdx] = sort(log_likelihood(:), 'descend');
N = 10;
maxIdxs = sortedIdx(1:N);
disp(['Top ', num2str(N), ' most discriminative words:']);
for i = 1:length(maxIdxs)
   disp([num2str(log_likelihood(maxIdxs(i))), words(maxIdxs(i))]);
end

% return the % of correctly classified articles
% each document (represented by a row in sparse table), multiply
% each word (a cell within a row) with the log probability in the doc

% for the training set
trainClassDoc1 = (trainDataSparse * log_doc1);
trainClassDoc2 = (trainDataSparse * log_doc2);
% then classify which document it is by whichever is larger
trainClassification = (trainClassDoc1 < trainClassDoc2) + 1;
trainCorrects = sum(trainClassification == trainLabel) / length(trainLabel);
disp(['Classified ', num2str(trainCorrects * 100), '% correct for training data.']);

% for the testing set
[test_log_doc1, test_log_doc2, ~] = naive_bayes_net(trainDataSparse, trainLabel);
testClassDoc1 = (testDataSparse * test_log_doc1);
testClassDoc2 = (testDataSparse * test_log_doc2);
% then classify which document it is by whichever is larger
testClassification = (testClassDoc1 < testClassDoc2) + 1;
testCorrects = sum(testClassification == testLabel) / length(testLabel);
disp(['Classified ', num2str(testCorrects * 100), '% correct for testing data.']);

