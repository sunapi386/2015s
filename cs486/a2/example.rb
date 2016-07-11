class Factor
  attr_accessor :variables, :values
  def initialize(variables, values)
    @variables = variables # holds the names of each variable
    @values = values       # holds the mapping between variable assignments to probability
  end

  def self.restrict(factor, variable, value)
    index = factor.variables.index variable
    factor.values = factor.values.select{ |element| element[index].eql? value } if index
  end

  def self.multiply(factor1, factor2)
    return factor1.clone if factor2.nil?
    return factor2.clone if factor1.nil?
    # puts "multiply #{factor1.values.values} #{factor2.values.values}"

    # join of variable names from both factor
    new_variables = (factor1.variables | factor2.variables).sort

    # index of the variable names in original factors, nil if not in the original factors
    variable_map1 = new_variables.map{|variable| factor1.variables.index variable}
    variable_map2 = new_variables.map{|variable| factor2.variables.index variable}

    # holds the new mapping between variable assignments to probability
    new_values = {}

    # iterate through all possible variable assignments
    (0...2**new_variables.size).each do |i|
      new_assignments = [] # holds an assignment for newly created factor
      assignments1 = []    # holds corresponding assignment for factor1
      assignments2 = []    # holds corresponding assignment for factor2

      # use bit mapping to generate a possible variable assignment
      # value is assigned from least significant bit to most significant bit
      (0...new_variables.size).each do |index|
        assignment = (i / (2 ** index)).even?
        new_assignments << assignment

        # only pipe in variable assignment if that variable exists in original factors
        assignments1 << assignment unless variable_map1[index].nil?
        assignments2 << assignment unless variable_map2[index].nil?
      end
      value1 = factor1.values[assignments1]
      value2 = factor2.values[assignments2]
      new_values[new_assignments] = value1 * value2 if (value1 and value2)
    end
    Factor.new(new_variables, new_values)
  end

  def self.sumout(factor, variable)
    # puts "sumout #{factor.values.values} #{variable}"
    index = factor.variables.index variable
    if (index)
      # drop given variable from factor variable names
      factor.variables.delete variable

      # remove assignment of given variable from assignment to probability mapping
      # note this would convert the hash to a nested array
      factor.values.each do |element|
        element.first.delete_at index
      end

    end
    new_values = {} # holds new assignments to probability mapping
    factor.values.each do |each|
      assignment = each.first # get the assignment

      # create the entry if there is no such assignment
      # otherwise, simply add to existing mapping
      value = new_values[assignment]
      if (value)
        new_values[assignment] += each.last
      else
        new_values[assignment] = each.last
      end
    end

    # assign the new mapping to factor
    factor.values = new_values
  end

  def self.normalize(factor)
    sum = factor.values.map{|element| element.last}.inject(0.0, :+)
    factor.values.each do |key, value|
      factor.values[key] = value/sum unless sum <= 0
    end
  end

  def self.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence_list)
    evidence_list.each do |evidence|
      factor_list.each do |factor|
        Factor.restrict(factor, evidence.first, evidence.last)
      end
    end

    product_factor = nil
    factor_list.each do |factor|
      product_factor = Factor.multiply(product_factor, factor)
    end

    ordered_list_of_hidden_variables.each do |variable|
      Factor.sumout(product_factor, variable)
    end

    Factor.normalize(product_factor)

    return product_factor
  end

end

# OC=Factor.new(["OC"], {[true] => 0.6, [false] => 0.4})
# Fraud = Factor.new(["Fraud", "Trav"], {[true, true] => 0.01, [true, false] => 0.004, [false, true] => 0.99, [false, false] => 0.996})
# Trav = Factor.new(["Trav"], {[true] => 0.05, [false] => 0.95})
# FP = Factor.new(["FP", "Fraud", "Trav"], {[true, true, true] => 0.9, [true, true, false] => 0.1, [true, false, true] => 0.9, [true, false, false] => 0.01, [false, true, true] => 0.1, [false, true, false] => 0.9, [false, false, true] => 0.1, [false, false, false] => 0.99})
# IP = Factor.new(["Fraud", "IP", "OC"], {[true, true, true] => 0.02, [true, true, false] => 0.11, [true, false, true] => 0.98, [true, false, false] => 0.989, [false, true, true] => 0.01, [false, true, false] => 0.001, [false, false, true] => 0.99, [false, false, false] => 0.999})
# CRP = Factor.new(["CRP", "OC"], {[true, true] => 0.1, [true, false] => 0.001, [false, true] => 0.9, [false, false] => 0.999})


OC = Factor.new(["OC"], {
    [true] => 0.75,
    [false] => 1 - 0.75})
Fraud = Factor.new(["Fraud", "Trav"], {
    [true, true] => 0.01,
    [true, false] => 0.004,
    [false, true] => 1 - 0.01,
    [false, false] => 1 - 0.004})
Trav = Factor.new(["Trav"], {
    [true] => 0.05,
    [false] => 1 - 0.05})
FP = Factor.new(["FP", "Fraud", "Trav"], {
    [true, true, true] => 0.9,
    [true, true, false] => 0.10,
    [true, false, true] => 0.9,
    [true, false, false] => 0.01,
    [false, true, true] => 0.1,
    [false, true, false] => 0.9,
    [false, false, true] => 0.1,
    [false, false, false] => 1 - 0.01})
IP = Factor.new(["Fraud", "IP", "OC"], {
    [true, true, true] => 0.02,
    [true, true, false] => 0.011,
    [true, false, true] => 0.98,
    [true, false, false] => 0.989,
    [false, true, true] => 0.01,
    [false, true, false] => 0.001,
    [false, false, true] => 0.99,
    [false, false, false] => 0.999})
CRP = Factor.new(["CRP", "OC"], {
    [true, true] => 0.1,
    [true, false] => 0.001,
    [false, true] => 0.9,
    [false, false] => 0.999})





puts "****************************Question 2B****************************"
factor_list = [Fraud.clone, Trav.clone]
query_variables = ["Fraud"]
ordered_list_of_hidden_variables = ["Trav", "FP", "IP", "OC", "CRP"]
evidence = {}
result = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
puts "Pr(Fraud)"
puts result.values.inspect

factor_list = [OC.clone, Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone]
evidence = {"FP" => true, "IP" => false, "CRP" => true}
result = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
puts "Pr(Fraud|fp ~ip crp)"
puts result.values.inspect

puts "****************************Question 2C****************************"
factor_list = [OC.clone, Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone]
query_variables = ["Fraud"]
ordered_list_of_hidden_variables = ["Trav", "FP", "IP", "OC", "CRP"]
evidence = {"FP" => true, "IP" => false, "CRP" => true, "Trav" => true}

result = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
puts "Pr(Fraud|fp ~ip crp trav)"
puts result.values.inspect

puts "****************************Question 2D****************************"
factor_list = [OC.clone, Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone]
query_variables = ["Fraud"]
ordered_list_of_hidden_variables = ["Trav", "FP", "IP", "OC", "CRP"]
evidence = {"IP" => true}

result = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
puts "Pr(Fraud|ip)"
puts result.values.inspect

factor_list = [OC.clone, Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone]
query_variables = ["Fraud"]
ordered_list_of_hidden_variables = ["Trav", "FP", "IP", "OC", "CRP"]
evidence = {"Trav" => false, "IP" => true, "CRP" => true, "FP" => false}

result = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
puts "Pr(Fraud|~trav ip crp ~fp)"
puts result.values.inspect

Utility = Factor.new(["Block", "Fraud"], {[true, true] => 0.0, [true, false] => -10.0, [false, true] => -1000.0, [false, false] => 5.0})
puts "****************************Question 3B****************************"
factor_list = [OC.clone, Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone]
query_variables = ["Fraud"]
ordered_list_of_hidden_variables = ["Trav", "FP", "IP", "OC", "CRP"]
evidence = {"IP" => false, "FP" => true, "CRP" => true}

fraud = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
result = Factor.sumout(Factor.multiply(fraud,Utility), "Fraud")
puts "E(Block|~ip fp crp)"
puts result.values.inspect


puts "****************************Question 3C****************************"
factor_list = [OC.clone, Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone]
query_variables = ["Fraud"]
ordered_list_of_hidden_variables = ["Trav", "FP", "IP", "OC", "CRP"]
evidence = {"IP" => false, "FP" => true, "CRP" => true, "Trav" => true}

fraud = Factor.inference(factor_list, query_variables, ordered_list_of_hidden_variables, evidence)
result = Factor.sumout(Factor.multiply(fraud,Utility), "Fraud")
puts "E(Block|~ip fp crp travel)"
puts result.values.inspect
