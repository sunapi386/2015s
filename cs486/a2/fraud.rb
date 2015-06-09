require 'matrix'

# Factors data-structure:
# variable names of the factor are stored in a string, which also indexes
# each possible assignment is used to index into a table of probabilities
# Example:
# Factor.new("CR",[0.8, 0.2,0.2,0.8])
# => #<Factor: @names="CR", @table={[1, 1]=>0.8, [1, 0]=>0.2, [0, 1]=>0.2, [0, 0]=>0.8}>
class Factor
    attr_accessor :names
    attr_accessor :table

    def initialize(varnames, values)
    # values expected to be 2^varnames.size in reverse sorted order (1s to 0s)
        raise MismatchSizeError unless 2 ** varnames.size == values.size
        @names = varnames
        @table = Hash.new(2 ** @names.size)
        assignments(@names.size).each_with_index { |a, i| @table[a] = values[i] }
    end

    private
    # all methods below this are private

    def assignments(n)
    # n is int, returns 2^n assignments array
        return [[0],[1]] if n == 1
        a = assignments(n-1)
        b1 = a.collect { |e| e + [0] }
        b2 = a.collect { |e| e + [1] }
        (b1 + b2).sort.reverse
    end

end

def restrict(factor, variable, value)
# restricts a variable to some value
    raise Error unless factor.names.include?(variable) && (value == 0 || value == 1)
    f = factor.clone
    f.names = factor.names.clone
    f.table = Marshal.load(Marshal.dump(factor.table))

    idx = f.names.index(variable)

    # remove entries not equal to value
    f.table = f.table.delete_if { |k, v| k[ idx ] != value }

    # change key names
    new_table = Hash.new(f.table.size)
    f.table.each do |key, value|
        key.delete_at(idx)
        new_table[key] = value
    end
    f.table = new_table

    # remove variable name
    f.names = f.names.delete(variable)
    return f
end

def multiply(factor1, factor2)
    # diff factor.names
    common_name = (factor1.names.split("") & factor2.names.split(""))
    # xor factor.names
    new_names = (factor1.names.split("") | factor2.names.split("")) - common_name
    # convert to strings
    common_name = common_name.join("")
    new_names = new_names.join("")
    # new probabilities
    new_values = Array.new(2 ** new_names.size) {0}

    [0,1].each do |bool|
        tmp1 = restrict(factor1, common_name, bool)
        tmp2 = restrict(factor2, common_name, bool)

        m1 = Matrix[tmp1.table.values]
        m2 = Matrix[tmp2.table.values]

        half_sum = (m1.t * m2).to_a.flatten

        # add half_sum to new_values
        new_values = new_values.zip(half_sum).map {|a| a.inject(:+).round(5) }
    end

    Factor.new(new_names, new_values)
end

def sumout(factor, variable)
    f0 = restrict(factor, variable, 0)
    f1 = restrict(factor, variable, 1)

    # merge the two factors
    new_values = f0.table.values.zip(f1.table.values).map {|row| row.inject(:+) }

    Factor.new(f0.names, new_values)
end

def normalize(factor)
    sum = factor.table.values.inject(:+)
    new_values = factor.table.values.collect {|v| v / sum }
    Factor.new(factor.names, new_values)
end

# inference: computes Pr(queryVariables|evidenceList) by variable elimination
def inference(factorList, queryVariables, orderedListOfHiddenVariables, evidenceList)

    factorList.collect do |factor|
        # restrict factors in factorList according to evidence in evidenceList
        evidenceList.each do |evidence, value|
            restrict(factor, evidence, value)
        end
    end
    .collect do |factor|
    # sumout hidden variables from factors in factorList,
    # in order given in orderedListOfHiddenVariables
        orderedListOfHiddenVariables
        sumout(factor, variable)
    end
    # normalize
    .collect do |factor|
        normalize(factor)
    end


end


f_c = Factor.new("C", [0.5,0.5])
f_cs = Factor.new("CS",[0.1, 0.9, 0.5, 0.5])
f_cr1 = Factor.new("CR",[0.8, 0.2,0.2,0.8])
f_srw = Factor.new("SRW", [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])

f_sr = restrict(f_srw, "W", 1)
f_cr2 = multiply(f_cs, f_sr)
# f_1 = multiply(f_c, f_cr1)
# f_cr3 = multiply(f_cr1, f_cr2)

# sumout example from lecture 8 slide 13
f_ex = Factor.new("ab", [0.9,0.1,0.4,0.6])
f_ex2 = sumout(f_ex, "a")
f_ex3 = normalize(f_ex2)

# populate evidenceList: maps variable to value
evidenceList = Hash.new()
evidenceList["A"] = 1
evidenceList["B"] = 0

# populate factorList:
factorList = []
factorList << Factor.new("C", [0.5,0.5])
factorList << Factor.new("CS",[0.1, 0.9, 0.5, 0.5])
factorList << Factor.new("CR",[0.8, 0.2,0.2,0.8])
factorList << Factor.new("SRW", [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])

# populate
