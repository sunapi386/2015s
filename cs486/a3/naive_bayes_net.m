function [log_doc1, log_doc2, log_likelihood] = naive_bayes_net(matrix, label)

% split training set into two documents
doc1 = [];
doc2 = [];
for i = 1:length(label)
   if label(i) == 1
       doc1 = [doc1; matrix(i,:)];
   else
       doc2 = [doc2; matrix(i,:)];
   end
end

% calc Pr(word|label1) and Pr(word|label2)
pr_word_doc1 = zeros(length(matrix(1,:)),1);
pr_word_doc2 = zeros(length(matrix(1,:)),1);

% start count at 1 for Laplace smoothing
for word = 1:length(matrix(1,:))
   count = 1;
   for i = 1:size(doc1, 1)
      count = count + doc1(i,word);
   end
   pr_word_doc1(word) = count / size(doc1, 1);

   count = 1;
   for i = 1:size(doc2, 1)
      count = count + doc2(i,word);
   end
   pr_word_doc2(word) = count / size(doc2, 1);

end

log_doc1 = log(pr_word_doc1);
log_doc2 = log(pr_word_doc2);
log_likelihood = abs(log_doc1 - log_doc2);

end
