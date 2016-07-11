class Node
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
      print "Labels don't match documents, abort!"
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
      leaves.append
    else
      leaves.append(@yes_child.get_leaves.collect{ |leaf| leaf })
      leaves.append(@no_child.get_leaves.collect{ |leaf| leaf })
      return leaves
    end
  end

  def is_leaf
    @value.is_a?(String)
  end

  def print_tree(prefix, words)
    if @value.is_a?(String)
       print prefix, @value
    else
      print prefix, words[@value]
    end
    print 'Info Gain:', @info_gain
    if @yes_child and @no_child
      @yes_child.print_tree('#{words[@value]} yes child:', words)
      @no_child.print_tree('#{words[@value]} no child:', words)
    end

  end
end