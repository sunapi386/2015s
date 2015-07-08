loadScript

% split training set into two documents
doc1 = [];
doc2 = [];
for i = 1:length(trainLabel)
   if trainLabel(i) == 1
       doc1 = [doc1; trainDataSparse(i,:)];
   else
       doc2 = [doc2; trainDataSparse(i,:)];
   end
end

% calc Pr(word|label1) and Pr(word|label2)
word_likelihood1 = zeros(length(trainDataSparse(1,:)),1);
word_likelihood2 = zeros(length(trainDataSparse(1,:)),1);

for word = 1:length(trainDataSparse(1,:))
   count = 1;
   for i = 1:size(doc1, 1)
      count = count + doc1(i,word); 
   end
   word_likelihood1(word) = count / size(doc1, 1);
   
   count = 2;
   for i = 1:size(doc2, 1)
      count = count + doc2(i,word); 
   end
   word_likelihood2(word) = count / size(doc2, 1);
   
end

log_likelihood = abs(log(word_likelihood1) - log(word_likelihood2));

% list the N most discrimative word features
% get the indices of the N largest elements in a matrix
[sortedVals, sortedIdx] = sort(log_likelihood(:), 'descend');
N = 10;
maxIdxs = sortedIdx(1:N);
disp(['Top ', num2str(N), ' words are:']);
disp(words(maxIdxs))
