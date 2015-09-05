import numpy as np
from sklearn.naive_bayes import GaussianNB
from sklearn.linear_model import LogisticRegression

from sknn.mlp import Classifier as NN_Classifier, Layer

SegmentNum = 10

def flatten(lst):
    return [item for sublist in lst for item in sublist]

class Classifier:
    def __init__(self, source, fold=2):
        self.label_num = len(source)
        self.train = [[] for x in source]
        self.test = [[] for x in source]
        prob = (fold - 1) / float(fold)
        for x in range(len(source)):
            for y in source[x]:
                gamble = np.random.uniform() 
                if gamble > prob:
                    self.test[x].append(y)
                else:
                    self.train[x].append(y)

    def get_confusion_matrix(self):
        self.confusion = [[sum(1 for z in self.result[x] if z == y) for y in \
                range(self.label_num)] for x in range(self.label_num)]
                
class Hetero(Classifier):
    def __init__(self, model, source, fold=2):
        Classifier.__init__(self, source, fold)
        self.model = model
        def partition(matrix):
            segment_len = len(matrix) / SegmentNum
            return np.asarray([np.mean(matrix[x * segment_len:(x + 1) * segment_len], axis=0) for x in range(SegmentNum)]).flatten()
        self.train = [[partition(y) for y in x] for x in self.train]
        self.test = [[partition(y) for y in x] for x in self.test]
        self.train_label = [[x for y in self.train[x]] for x in range(len(self.train))]
        self.train = flatten(self.train)
        self.train_label = flatten(self.train_label)
        self.model.fit(np.asarray(self.train), np.asarray(self.train_label))

    def predict(self):
        self.result = [self.model.predict(np.asarray(x)) for x in self.test]
        Classifier.get_confusion_matrix(self)

class Voting(Classifier):
    def __init__(self, model, source, fold=2):
        Classifier.__init__(self, source, fold)
        self.model = model
        self.train_concat = [np.concatenate(x) for x in self.train]
        self.train_label = flatten([[l for x in \
                range(self.train_concat[l].shape[0])] for l in range(self.label_num)])
        self.train_concat = np.concatenate(self.train_concat)
        self.model.fit(np.asarray(self.train_concat), np.asarray(self.train_label))

    def predict(self):
        def vote(song):
           res = self.model.predict(song)
           count = [sum(1 for y in res if y == x) for x in range(self.label_num)]
           return count.index(max(count))
        self.result = [[vote(song) for song in genre] for genre in self.test]
        Classifier.get_confusion_matrix(self)

def voting_NN(data_transform, num_interation=10, num_features=12):
    return NN_Classifier(
        layers = [
            Layer(data_transform, units=num_features),
            Layer('Softmax')
        ],
        learning_rate=0.1,
        n_iter=num_interation
    )

def weighted_NN(data_transform, num_interation=100, num_features=12):
    return NN_Classifier(
        layers = [
            Layer(data_transform, units=SegmentNum, dropout=0.3),
            Layer('Softmax')
        ],
        learning_rate=0.01,
        n_iter=num_interation
    )
