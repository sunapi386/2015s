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
        @table = {}
        assignments(Math.log2(values.size)).each_with_index { |a, i| @table[a] = values[i] }
    end

    def clone
        Factor.new(@names.clone, @table.values.clone)
    end

    private
    # all methods below this are private

    def assignments(n)
    # n is int, returns 2^n assignments array
        return [[1],[0]] if n == 1
        a = assignments(n-1)
        b1 = a.collect { |e| e + [0] }
        b2 = a.collect { |e| e + [1] }
        (b1 + b2).sort.reverse
    end

end

def restrict(factor, variable, value)
# restricts a variable to some value
    raise NoCommonNamesError unless factor.names.include?(variable)
    f = factor.clone
    idx = f.names.index(variable)

    # remove entries not equal to value
    f.table.delete_if { |k, v| k[ idx ] != value }

    # # change key names
    new_table = Hash.new(f.table.size)
    f.table.each do |key, value|
        key.delete_at(idx)
        new_table[key] = value
    end
    f.table = new_table

    # # remove variable name
    f.names.slice!(idx)
    return f
end

def multiply(f1, f2)
    common_name = (f1.names.split("") & f2.names.split("")).join("")
    # swap f1 with f2 if need be (to mult vars next to each other)
    # FIXME: this may be buggy
    name_order1 = ((f1.names + f2.names).rindex(common_name) - (f1.names + f2.names).index(common_name)).abs
    name_order2 = ((f2.names + f1.names).rindex(common_name) - (f2.names + f1.names).index(common_name)).abs
    if(name_order1 > name_order2)
        tmp = f1
        f1 = f2
        f2 = tmp
    end
    new_names = (f1.names + f2.names)
    new_names.slice!(common_name)


    n1_idx = f1.names.index(common_name)
    n2_idx = f2.names.index(common_name)
    len = common_name.size - 1

    new_values = f1.table.collect do |k1, v1|
        f2.table.collect do |k2, v2|
            if k1[n1_idx..n1_idx + len] == k2[n2_idx..n2_idx + len]
                # puts "#{k1} #{v1} #{k2} #{v2}"
                (v1 * v2).round(5)
            end
        end
    end.flatten.compact

    Factor.new(new_names, new_values)
end

def sumout(factor, variable)
    raise NoCommonNamesError unless factor.names.include?(variable)
    f0 = restrict(factor, variable, 0)
    f1 = restrict(factor, variable, 1)
    name = factor.names.clone
    # merge the two factors
    new_values = f0.table.values.zip(f1.table.values).map {|row| row.inject(:+).round(5) }
    name.slice!(name.index(variable))
    new_factor = Factor.new(name, new_values)
    # return sumout(new_factor, variable) if new_factor.names.include?(variable)
    # new_factor
end

def normalize(factor)
    sum = factor.table.values.inject(:+)
    new_values = factor.table.values.collect {|v| v / sum }
    Factor.new(factor.names, new_values)
end

# inference: computes Pr(queryVars|evidences) by variable elimination
def inference(factors, queryVars, ordering, evidences)
    raise NoCommonNamesError unless factors.is_a?(Array) && queryVars.is_a?(String) && ordering.is_a?(String) && evidences.is_a?(Hash)

    # restrict factors w.r.t. evidences
    # restricted = factors.each do |factor|
    #     evidences.split("").each do |evidence, value|
    #         puts "A"
    #         factor = restrict(factor, evidence, value)
    #     end
    # end


    # sumout factors w.r.t. ordering
    while factors.size > 1
        last = factors.pop
        second_last = factors.pop
        common_name = (last.names.split("") & second_last.names.split("")).join("")
        mt = multiply(second_last, last)
        so = sumout(mt, common_name)
        factors.push(so)
    end



    # normalize
    factors.each do |f|
        f = normalize(f)
    end

end

# Example A->B->C
f1 = Factor.new("A",[0.9,0.1])
f2 = Factor.new("AB",[0.9,0.1,0.4,0.6])
f3 = Factor.new("BC",[0.7,0.3,0.2,0.8])
factors = [f1, f2, f3]
queryVars = "C"
ordering = "AB"
evidences = {}
inference(factors, queryVars, ordering, evidences)


# populate evidences: maps variable to value
evidences = Hash.new()
evidences["A"] = 1
evidences["B"] = 0

# populate factorList:
factorList = []
factorList << Factor.new("C", [0.5,0.5])
factorList << Factor.new("CS",[0.1, 0.9, 0.5, 0.5])
factorList << Factor.new("CR",[0.8, 0.2,0.2,0.8])
factorList << Factor.new("SRW", [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])

# populate



