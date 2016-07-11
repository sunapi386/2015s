import csv
import math

class Node:
    def __init__(self, word, depth):
        self.word = word
        self.depth = depth
        self.labels = []
        self.documents = []
        self.positives = None
        self.negatives = None
        self.importance = None
        self.idx_best_word = None

    def add_docs_and_labels(self, documents, labels):
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

    def print_tree(self, prefix, words):
        if type(self.word) is str:
            print prefix, self.word
        else:
            print prefix, words[self.word]
        print "Information gain:", self.importance
        if self.positives and self.negatives:
            self.positives.print_tree('%s positive child:'%words[self.word], words)
            self.negatives.print_tree('%s negative child:'%words[self.word], words)















# returns accuracy (% of documents correctly classified) in the tree given  its data and labels
def test_decision_tree(tree, sparse_data, labels):
    # classify every document in data using the tree:
    classifications = []
    for doc in sparse_data:
        classifications.append( classify( tree, doc ) )
    correct = 0
    for i in range( len( labels )):
        if labels[i] == classifications[i]:
            correct = correct+1
    return float(correct) / len (labels)

def classify( root, doc ):
    node = root
    while not node.is_child():
        # check if the word is in the document
        if doc[node.word] == 1:
            node = node.positives
        else:
            node = node.negatives
    return node.word

def plurality(word_idx, sparse_data, labels, word):
    count1 = 0
    count2 = 0
    for i in range(len(sparse_data)):
        if sparse_data[i][word_idx] == word:
            if labels[i] == '1':
                count1 = count1+1
            else:
                count2 = count2+1
    if count1 > count2:
        return '1'
    else:
        return '2'

# returns the entropy of a boolean random variable that is true with the probability q
# q must be a floating point word
def entropy(q):
    if q == 0 or q == 1:
        return 0
    entropy = -1* (q * math.log(q,2) + (1-q) * math.log(1-q, 2) )
    return entropy


def information_gain( word_idx, train_data_sparse, labels ):
    p = labels.count('2')
    n = len(labels) - p
    # if there are no documents left over, return 0 (nothing left to gain)
    if p+n == 0:
        return 0.0
    H = entropy( float(p) / (p+n) )

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
        # check to see if any of the documents contained the word word
        if pk+nk != 0:
            remainder = remainder + (float(pk+nk) / (p+n)) * entropy( float(pk)/ (pk+nk) )
        else:
            remainder = remainder + 0
    return H - remainder


def decision_tree_learn(matrix, labels, test_data, test_labels, words, max_depth):
    info_gain_word = []
    for word_idx in range(len(matrix[0])):
        info_gain_word.append( information_gain( word_idx, matrix, labels ) )

    best_word = info_gain_word.index( max(info_gain_word) )
    depth = 0
    root = Node(best_word, depth)
    print "Best word: ", words[best_word], " info gain: ", max(info_gain_word)

    yes_docs = []
    yes_labels = []
    no_docs = []
    no_labels = []
    for i in range(len(matrix)):
        label = labels[i]
        doc = matrix[i]
        if doc[best_word]:
            yes_docs.append(doc)
            yes_labels.append(label)
        else:
            no_docs.append(doc)
            no_labels.append(label)

    root.add_negative( Node(plurality(best_word, no_docs, no_labels, 0), depth))
    root.add_positive( Node(plurality(best_word, yes_docs, yes_labels, 1), Node))

    root.positives.add_docs_and_labels( yes_docs, yes_labels )
    root.negatives.add_docs_and_labels( no_docs, no_labels )
    root.importance = max(info_gain_word)
    depth += 1
    test_percent = []
    train_percent = []
    while depth < max_depth:
        print "make depth node ", depth+1
        test_percent.append(test_decision_tree(root, test_data, test_labels))
        train_percent.append(test_decision_tree(root, matrix, labels))
        print "classified %f percent training documents correctly" % train_percent[depth-1]
        print "classified %f percent testing documents correctly" % test_percent[depth-1]

        leaves = root.childrens()
        for leaf in leaves:
            # check if we've already calculated the gain for the leaf
            if leaf.importance == None:
                # find the best word at each leaf by calculating the gain for
                # all words and then take the max
                info_gain_word = []
                for i in range(len(matrix[0])):
                    # find the information gain or info gain times number of documents for each leaf
                    info_gain_word.append( information_gain( i, leaf.documents, leaf.labels )*len(leaf.documents) )
                    #info_gain_word.append( information_gain( i, leaf.documents, leaf.labels ) )
                leaf.importance = max(info_gain_word)
                leaf.idx_best_word = info_gain_word.index( max(info_gain_word) )
        leaves_gain = [leaf.importance for leaf in leaves]
        # find the best leaf based on the info gain
        best_leaf = leaves[leaves_gain.index( max(leaves_gain) )]
        # expand the best leaf
        best_leaf.word = best_leaf.idx_best_word

        print "Selected word:", words[best_leaf.word]
        print "info gain:", best_leaf.importance


        yes_docs = []
        yes_labels = []
        no_docs = []
        no_labels = []
        for i in range(len(best_leaf.documents)):
            label = best_leaf.labels[i]
            doc = best_leaf.documents[i]
            if doc[best_leaf.idx_best_word]:
                yes_docs.append(doc)
                yes_labels.append(label)
            else:
                no_docs.append(doc)
                no_labels.append(label)

        best_leaf.add_negative( Node(plurality(best_leaf.idx_best_word, best_leaf.documents, best_leaf.labels, 0), depth))
        best_leaf.add_positive( Node(plurality(best_leaf.idx_best_word, best_leaf.documents, best_leaf.labels, 1), depth))

        best_leaf.positives.add_docs_and_labels( yes_docs, yes_labels )
        best_leaf.negatives.add_docs_and_labels( no_docs, no_labels )
        depth = depth+1
    return root













# load given data
words = []
with open('words.txt', 'r') as f:
    for line in f:
        words.append( line.split()[0] )
print len(words), " words"

train_data = []
with open('trainData.txt', 'r') as f:
    for line in f:
        digits = [int(x) for x in line.split()]
        train_data.append( digits )

train_labels = []
with open('trainLabel.txt', 'r') as f:
    for line in f:
        train_labels.append(line.split()[0])
print len(train_labels), " training documents",

test_data = []
with open('testData.txt', 'r') as f:
    for line in f:
        digits = [int(x) for x in line.split()]
        test_data.append( digits )

test_labels = []
with open('testLabel.txt', 'r') as f:
    for line in f:
        test_labels.append(line.split()[0])
print len(test_labels), " testing documents",


# create mega-huge matrix
train_matrix = [[0] * len(words) for i in range(len(train_labels))]
for i in train_data:
    train_matrix[ i[0]-1 ][ i[1]-1 ] = 1
test_matrix = [[0] * len(words) for i in range(len(test_labels))]
for i in test_data:
    test_matrix[ i[0]-1 ][ i[1]-1 ] = 1

# make bunch of trees with different depths
max_depth = 10


tree = decision_tree_learn(train_matrix, train_labels, max_depth, test_matrix, test_labels, words )
print "Final training percent correct:", test_decision_tree( tree, train_matrix, train_labels )
print "Final test percent correct:", test_decision_tree( tree, test_matrix, test_labels )
tree.print_tree('', words)