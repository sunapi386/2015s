class Node
  attr_accessor :value, :yes_child, :no_child, :docs, :labels, :best_word_index, :info_gain
  def initialize(value)
    @value = value
    @yes_child = nil
    @no_child = nil
    @docs = []
    @labels = []
    @best_word_index = nil
    @info_gain = nil
  end


  def add_docs_and_labels(docs, labels)
    if docs.size == labels.size
      @docs = docs
      @labels = labels
    else
      puts "Labels don't match documents, abort!"
      return -1
    end
  end

  def add_yes_child( yes_node )
    @yes_child = yes_node
  end

  def add_no_child( no_node )
    @no_child = no_node
  end

  def get_leaves
    leaves = []
    if is_leaf
      leaves << self
    else
      leaves << (@yes_child.get_leaves.collect{ |leaf| leaf })
      leaves << (@no_child.get_leaves.collect{ |leaf| leaf })
      leaves
    end
  end

  def is_leaf
    @value.is_a?(String)
  end

  def print_tree(prefix, words)
    if @value.is_a?(String)
      puts "#{prefix} #{@value}"
    else
      puts "#{prefix} #{words[@value]}"
    end
    puts "Info Gain: #{@info_gain}"
    if @yes_child and @no_child
      @yes_child.print_tree('#{words[@value]} yes child:', words)
      @no_child.print_tree('#{words[@value]} no child:', words)
    end

  end
end

# returns accuracy (% of docs correctly classified) in the tree given  its data and labels
def test_decision_tree(tree, sparse_data, labels)
    # classify every document in data using the tree:
    classifications = []
    sparse_data.each do |doc|
        classifications << ( classify( tree, doc ) )
    end
    correct = 0
    labels.size.times do |i|
        if labels[i] == classifications[i]
            correct = correct+1
        end
    end
    correct / labels.size
end

def classify( root, doc )
    node = root
    while not node.is_leaf
        # check if the word is in the document
        if doc[node.value] == 1
            node = node.yes_child
        else
            node = node.no_child
        end
        node.value
    end
end



# Implements an iterative priority queue DTL algorithm
def dtl_iterative(sparse_data, labels, max_nodes, test_data, test_labels, words)
    # first, get the root node:
    info_list = []
    sparse_data[0].size.times do |word_index|
        info_list << ( information_gain( word_index, sparse_data, labels ) )
    end

    best_word = info_list.index( info_list.max )

    root = Node.new(best_word)
    puts "Selected word: #{words[best_word]}"
    puts "info gain: #{info_list.max}"

    yes_docs = []
    yes_labels = []
    no_docs = []
    no_labels = []
    sparse_data.size.times do |i|
        label = labels[i]
        doc = sparse_data[i]
        if doc[best_word]
            yes_docs << (doc)
            yes_labels << (label)
        else
            no_docs << (doc)
            no_labels << (label)
        end
    end

    root.add_no_child( Node.new(path_plurality_value(best_word, no_docs, no_labels, 0)) )
    root.add_yes_child( Node.new(path_plurality_value(best_word, yes_docs, yes_labels, 1)) )

    root.yes_child.add_docs_and_labels( yes_docs, yes_labels )
    root.no_child.add_docs_and_labels( no_docs, no_labels )
    root.info_gain = info_list.max
    n_nodes = 1
    test_percent = []
    train_percent = []
    while n_nodes < max_nodes
        puts "testing with #{n_nodes} nodes... "
        test_percent << (test_decision_tree(root, test_data, test_labels))
        train_percent << (test_decision_tree(root, sparse_data, labels))
        puts "classified #{train_percent[n_nodes-1]} percent training documents correctly"
        puts "classified #{test_percent[n_nodes-1]} percent training documents correctly"
        puts "adding node #{n_nodes+1} of #{max_nodes}"

        leaves = root.get_leaves()
        leaves.each do |leaf|
            # check if we've already calculated the gain for the leaf
            if leaf.is_a?(Node) && leaf.info_gain == Nil
                # find the best word at each leaf by calculating the gain for
                # all words and then take the max
                info_list = []
                sparse_data[0].size.times do |i|
                    # find the information gain or info gain times number of documents for each leaf
                    info_list << ( information_gain( i, leaf.docs, leaf.labels )*leaf.docs.size )
                    #info_list << ( information_gain( i, leaf.docs, leaf.labels ) )
                end
                leaf.info_gain = info_list.max
                leaf.best_word_index = info_list.index( info_list.max )
            end
        end
        leaves_gain = leaves.collect { |leaf| leaf.info_gain }
        # find the best leaf based on the info gain
        best_leaf = leaves[leaves_gain.index( leaves_gain.max )]
        # expand the best leaf
        best_leaf.value = best_leaf.best_word_index

        puts "Selected word: #{words[best_leaf.value]}"
        puts "info gain: #{best_leaf.info_gain}"


        yes_docs = []
        yes_labels = []
        no_docs = []
        no_labels = []
        best_leaf.docs.size.times do |i|
            label = best_leaf.labels[i]
            doc = best_leaf.docs[i]
            if doc[best_leaf.best_word_index]
                yes_docs << (doc)
                yes_labels << (label)
            else
                no_docs << (doc)
                no_labels << (label)
            end
        end

        best_leaf.add_no_child( Node.new(path_plurality_value(best_leaf.best_word_index, best_leaf.docs, best_leaf.labels, 0) ))
        best_leaf.add_yes_child( Node.new(path_plurality_value(best_leaf.best_word_index, best_leaf.docs, best_leaf.labels, 1) ))

        best_leaf.yes_child.add_docs_and_labels( yes_docs, yes_labels )
        best_leaf.no_child.add_docs_and_labels( no_docs, no_labels )
        n_nodes = n_nodes + 1
    end
    # write the percentages correct to a .csv
    # with open('results_times_docs.csv', 'wb') as f:
    #     writer = csv.writer(f)
    #     writer.writerows([train_percent])
    #     writer.writerows([test_percent])

    return root
end

def path_plurality_value(word_index, sparse_data, labels, value)
    count1 = 0
    count2 = 0
    sparse_data.size.times do |i|
        if sparse_data[i][word_index] == value
            if labels[i] == '1'
                count1 = count1 + 1
            else
                count2 = count2 + 1
            end
        end
    end
    if count1 > count2
        return '1'
    else
        return '2'
    end
end

# returns the entropy of a boolean random variable that is true with the probability q
# q must be a floating point value
def entropy(q)
    return 0 if q == 0 or q == 1
    entropy = -1* (q * Math::log(q,2) + (1-q) * Math::log(1-q, 2) )
end

def information_gain( word_index, train_data_sparse, labels )
    p = labels.count('2')
    n = labels.size - p
    # if there are no documents left over, return 0 (nothing left to gain)
    return 0.0 if p+n == 0
    h = entropy( p / (p+n) )
    remainder = 0
    [0,1].each do |value|
        pk = 0
        nk = 0
        train_data_sparse.size.times do |doc|
            if train_data_sparse[doc][word_index] == value
                if labels[doc] == '2'
                    pk = pk+1
                else
                    nk = nk+1
                end
            end
            # check to see if any of the documents contained the word value
            if pk+nk != 0
                remainder = remainder + ((pk+nk) / (p+n)) * entropy( pk/ (pk+nk) )
            else
                remainder = remainder + 0
            end
        end
        h - remainder
    end
end


def main
  # load given data
  words = []
  words_file = File.new("words.txt")
  words_file.each_line do |line|
    words << line.strip

  end
  words_file.close

  train_labels = []
  train_label_file = File.new("trainLabel.txt")
  train_label_file.each_line do |line|
    train_labels << line.strip.to_i
  end
  train_label_file.close

  train_data = []
  train_data_file = File.new("trainData.txt")
  train_data_file.each_line do |line|
    train_data << [line.split[0].to_i, line.split[1].to_i]
  end
  train_data_file.close

  test_data = []
  test_data_file = File.new("testData.txt")
  test_data_file.each_line do |line|
    test_data << [line.split[0].to_i, line.split[1].to_i]
  end
  test_data_file.close

  test_labels = []
  test_label_file = File.new("testLabel.txt")
  test_label_file.each_line do |line|
    test_labels << line.strip.to_i
  end
  test_label_file.close


  puts "#{words.size} words"
  puts "#{train_labels.size} training docs"
  puts "#{test_labels.size} testing docs"

  # create unscalable big-huge matrix
  train_matrix = Array.new(train_labels.size) { Array.new(words.size) }
  train_data.each do |i|
    train_matrix[i[0] - 1][i[1] - 1] = 1
  end
  test_matrix =  Array.new(test_labels.size) { Array.new(words.size) }
  train_data.each do |i|
    train_matrix[i[0] - 1][i[1] - 1] = 1
  end

    # Build a decision tree using information gain:
    max_nodes = 10
    tree = dtl_iterative(train_matrix, train_labels, max_nodes, test_matrix, test_labels, words )
    puts "Final training percent correct:", test_decision_tree( tree, train_matrix, train_labels )
    puts "Final test percent correct:", test_decision_tree( tree, test_matrix, test_labels )
    tree.print_tree('', words)
end

main
