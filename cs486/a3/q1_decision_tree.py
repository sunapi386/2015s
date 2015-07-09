import csv
import math

# A decision node, corresponds to a word feature.
class Node:
	def __init__(self, word):
		self.word = word
		self.labels = []
		self.documents = []
		self.positives = None
		self.negatives = None
		self.importance = None
		self.idx_best_word = None

	def add_sample(self, documents, labels):
		self.documents = documents
		self.labels = labels

	def add_positive(self, pos):
		self.positives = pos

	def add_negative(self, neg):
		self.negatives = neg

	def childrens(self):
		leaves = []
		if self.is_child():
			leaves.append(self)
		else:
			[leaves.append(leaf) for leaf in self.positives.childrens()]
			[leaves.append(leaf) for leaf in self.negatives.childrens()]
		return leaves

	def is_child(self):
		return type(self.word) == str

	def printout(self, words, depth):
		if self.positives:
			self.positives.printout(words, depth + 1)

		print (depth * '--'), depth, '> ',

		if type(self.word) == str:
			print "[LEAF    ", self.word,
		else:
			print "[NOTLEAF ", words[self.word],
		print  " ", self.importance, "]"

		if self.negatives:
			self.negatives.printout(words, depth + 1)


# Classify document given a tree
def classify(root, doc):
	node = root
	while not node.is_child():
		if doc[node.word] == 1:
			node = node.positives
		else:
			node = node.negatives
	return node.word

# Returns % docs correctly classified using the tree
def test(tree, data, labels):
	correct = 0
	classifications = []
	for doc in data:
		classifications.append(classify(tree, doc))
	for i in range(len(labels)):
		if labels[i] == classifications[i]:
			correct += 1
	return float(correct) / len (labels)

# Most frequently seen
def plurality(word_idx, matrix, labels, word):
	count1 = 0
	count2 = 0
	for i in range(len(matrix)):
		if matrix[i][word_idx] == word:
			if labels[i] == '1':
				count1 = count1+1
			else:
				count2 = count2+1
	if count1 > count2:
		return '1'
	else:
		return '2'

# returns the entropy of a random variable that is true with the probability q
def entropy(q):
	if q == 0 or q == 1:
		return 0
	entropy = -1* (q * math.log(q,2) + (1-q) * math.log(1-q, 2))
	return entropy

# Importance is the information gain from the word
def importance(word_idx, train_data_sparse, labels):
	p = labels.count('2')
	n = len(labels) - p
	if p+n == 0:
		return 0.0

	H = entropy(float(p) / (p+n))
	remainder = 0
	for word in [0,1]:
		pk = 0
		nk = 0
		for doc in range(len(train_data_sparse)):
			if train_data_sparse[doc][word_idx] == word:
				if labels[doc] == '2':
					pk = pk+1
				else:
					nk = nk+1
		if pk+nk != 0:
			remainder = remainder + ((float(pk+nk) / (p+n)) *
									entropy(float(pk)/ (pk+nk)))
	return H - remainder

# Refer to AIMA chpt 20 decision tree learner algorithm
def decision_tree_learn(matrix, labels,
						test_data, test_labels,
						words, max_depth):
	# For each word, see how important it is.
	important_words = []
	for word_idx in range(len(matrix[0])):
		important_words.append(importance(word_idx, matrix, labels))
	# Use the most important word to start as root of decision tree
	important_word = important_words.index(max(important_words))
	root = Node(important_word)
	neg_docs = []
	neg_labels = []
	pos_docs = []
	pos_labels = []

	for i in range(len(matrix)):
		doc = matrix[i]
		label = labels[i]
		if doc[important_word]:
			pos_docs.append(doc)
			pos_labels.append(label)
		else:
			neg_docs.append(doc)
			neg_labels.append(label)

	root.add_negative(Node(plurality(important_word, neg_docs, neg_labels, 0)))
	root.add_positive(Node(plurality(important_word, pos_docs, pos_labels, 1)))
	root.positives.add_sample(pos_docs, pos_labels)
	root.negatives.add_sample(neg_docs, neg_labels)
	root.importance = max(important_words)
	depth = 1
	test_percent = []
	train_percent = []
	print "Depth\tTraining\tTesting   \tImportance\tWord"

	while depth < max_depth:
		test_percent.append(test(root, test_data, test_labels))
		train_percent.append(test(root, matrix, labels))
		leaves = root.childrens()

		for leaf in leaves:
			# check if already calculated leaf
			if leaf.importance == None:
				# find the best word, make it next leaf
				important_words = []
				for i in range(len(matrix[0])):
					# importance for each document
					important_words.append(
						importance(i, leaf.documents, leaf.labels) *
						len(leaf.documents)
					)

				leaf.importance = max(important_words)
				leaf.idx_best_word = important_words.index(max(important_words))

		leaves_gain = [leaf.importance for leaf in leaves]
		best_leaf = leaves[leaves_gain.index(max(leaves_gain))]
		# expand the best leaf
		best_leaf.word = best_leaf.idx_best_word

		print depth, "\t",
		print format(train_percent[depth-1], '.5f'), "\t",
		print format(test_percent[depth-1], '.5f'), "\t",
		print format(best_leaf.importance, '.5f'), "\t",
		print words[best_leaf.word]

		pos_docs = []
		pos_labels = []
		neg_docs = []
		neg_labels = []

		for i in range(len(best_leaf.documents)):
			label = best_leaf.labels[i]
			doc = best_leaf.documents[i]
			if doc[best_leaf.idx_best_word]:
				pos_docs.append(doc)
				pos_labels.append(label)
			else:
				neg_docs.append(doc)
				neg_labels.append(label)

		best_leaf.add_negative(
			Node(plurality(	best_leaf.idx_best_word,
							best_leaf.documents,
							best_leaf.labels,
							0))
		)
		best_leaf.add_positive(
			Node(plurality(	best_leaf.idx_best_word,
							best_leaf.documents,
							best_leaf.labels,
							1))
		)

		best_leaf.positives.add_sample(pos_docs, pos_labels)
		best_leaf.negatives.add_sample(neg_docs, neg_labels)
		depth += 1

	# write the percentages correct to a .csv
	with open('results.csv', 'wb') as f:
		writer = csv.writer(f)
		writer.writerows([train_percent])
		writer.writerows([test_percent])

	return root


# load given data
words = []
train_data = []
train_labels = []
test_data = []
test_labels = []
with open('words.txt', 'r') as f:
	for line in f:
		words.append(line.split()[0])
with open('trainData.txt', 'r') as f:
	for line in f:
		digits = [int(x) for x in line.split()]
		train_data.append(digits)
with open('trainLabel.txt', 'r') as f:
	for line in f:
		train_labels.append(line.split()[0])
with open('testData.txt', 'r') as f:
	for line in f:
		digits = [int(x) for x in line.split()]
		test_data.append(digits)
with open('testLabel.txt', 'r') as f:
	for line in f:
		test_labels.append(line.split()[0])
print len(words), "\twords"
print len(train_labels), "\ttraining documents"
print len(test_labels), "\ttesting documents"
# create unscalable big-huge matrix
train_matrix = [[0] * len(words) for i in range(len(train_labels))]
for i in train_data:
	train_matrix[i[0]-1][i[1]-1] = 1
test_matrix = [[0] * len(words) for i in range(len(test_labels))]
for i in test_data:
	test_matrix[i[0]-1][i[1]-1] = 1


# Build a decision tree using information gain:
max_depth = 22
root = decision_tree_learn(train_matrix, train_labels,
					test_matrix, test_labels,
					words, max_depth)
root.printout(words, 0)