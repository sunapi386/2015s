require 'matrix'
DETAILED = false
# Factors data-structure:
# variable names of the factor are stored in a string, which also indexes
# each possible assignment is used to index into a table of probabilities
# Example:
# Factor.new("CR",[0.8, 0.2,0.2,0.8])
# => #<Factor:
#   @names="CR",
#   @table={[1, 1]=>0.8, [1, 0]=>0.2, [0, 1]=>0.2, [0, 0]=>0.8}>
class Factor
    attr_accessor :names
    attr_accessor :table

    def initialize(varnames, values)
    # values expected to be 2^varnames.size in reverse sorted order (1s to 0s)
        raise MismatchSizeError unless 2 ** varnames.size == values.size
        @names = varnames
        @table = {}
        assignments(Math.log2(values.size)).each_with_index do |a, i|
            @table[a] = values[i]
        end
    end

    def clone
        Factor.new(@names.clone, @table.values.clone)
    end

    private # all methods below this are private
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
    return factor unless factor.names.include?(variable)
    f = factor.clone
    idx = f.names.index(variable)

    # remove entries not equal to value
    f.table.delete_if { |k, _| k[ idx ] != value }

    # change key names
    new_table = Hash.new(f.table.size)
    f.table.each do |key, value|
        key.delete_at(idx)
        new_table[key] = value
    end
    f.table = new_table

    # remove variable name
    f.names.slice!(idx)
    return f
end

def multiply(first, second)
    return first.clone if second.nil?
    return second.clone if first.nil?

    def is_desired(k1, mapping, k2)
        # returns true if k1 == k2 given mapping of bits from k1 to k2
        # e.g. k1 = [X, 0, 1] and k2 = [1, 0, X]
        # where k1's index: ["X", "A", "B"] and k2's index: ["B", "A", "D"]
        #                      0,   1,   2                     0,   1,   2
        # mapping would be: {1 => 1, 2 => 0}
        # we want to return true since k1 == k2 given this index
        # more ex:
        # is_desired?([1, 0, 0], [0, 0, 1], {1=>1, 2=>0}) # true
        # is_desired?([0, 0, 0], [0, 0, 1], {1=>1, 2=>0}) # true
        # is_desired?([0, 0, 0], [0, 0, 0], {1=>1, 2=>0}) # true
        # is_desired?([1, 0, 0], [0, 0, 0], {1=>1, 2=>0}) # true
        # is_desired?([1, 1, 0], [0, 0, 0], {1=>1, 2=>0}) # false

        mapping.each do |from, to|
            return false unless k1[from] == k2[to]
        end
        true
    end

    common_names = (first.names & second.names)
    new_names = (first.names | second.names)

    # make mapping of common names from first => second
    mapping = {}
    common_names.each do |name|
        mapping[first.names.index(name)] = second.names.index(name)
    end

    # multiply value1 with value2 if key1 has same entry in key2
    new_values = first.table.collect do |k1, v1|
        second.table.collect do |k2, v2|
            if is_desired(k1, mapping, k2)
                (v1 * v2)
            end
        end
    end.flatten.compact
    Factor.new(new_names, new_values)
end

def sumout(factor, variable)
    return factor.clone unless factor.names.include?(variable)
    f0 = restrict(factor, variable, 0)
    f1 = restrict(factor, variable, 1)
    name = factor.names.clone
    # merge the two factors
    new_values = f0.table.values.zip(f1.table.values).map {|row| row.inject(:+)}
    name.delete_at(name.index(variable))
    Factor.new(name, new_values)
end

def normalize(factor)
    sum = factor.table.values.inject(:+)
    new_values = factor.table.values.collect {|v| v / sum }
    Factor.new(factor.names, new_values)
end

# inference: computes Pr(queryVars|evidences) by variable elimination
def inference(factors, queryVars, ordering, evidences)
    raise NoCommonNamesError unless factors.is_a?(Array) &&
                                    queryVars.is_a?(Array) &&
                                    ordering.is_a?(Array) &&
                                    evidences.is_a?(Hash)

    # restrict factors w.r.t. evidences
    puts "\t\tInference Step 0 (Unmodified Factors)" if DETAILED
    factors.each { |f| puts f.inspect } if DETAILED
    evidences.each do |var, val|
        factors.each_with_index do |f,i|
            factors[i] = restrict(factors[i], var, val)
        end
    end
    puts "\t\tInference Step 1 (Factors After Restriction)" if DETAILED
    factors.each { |f| puts f.inspect } if DETAILED

    # multiply everything into this factor
    puts "\t\tInference Step 2 (Multiply)" if DETAILED
    prod_factor = nil
    factors.each do |factor|
        prod_factor = multiply(prod_factor, factor)
        puts "Product Factor #{prod_factor.inspect}" if DETAILED
    end

    puts "\t\tInference Step 3 (Sumout)" if DETAILED
    ordering.each do |var|
        prod_factor = sumout(prod_factor, var)
        puts "Product after sumout #{var}: #{prod_factor.inspect}" if DETAILED
    end

    puts "\t\tInference 4 (Normalized)" if DETAILED
    puts normalize(prod_factor).inspect if DETAILED
    normalize(prod_factor)
end

def print_summary(result, evidences)
    print "Pr(#{result.names.join(", ")}"
    print " | " if evidences.size > 0
    evidences.each_with_index do |e, idx|
        print "~" if e.last == 0
        print "#{e.first}"
        print ", " unless idx == evidences.size - 1
    end
    print ") = #{result.table.inspect}\r\n"
    puts
end

def print_change(f1, f2)
    puts "Changes in fraud probability (rounded 8 decimals):"
    before = f1.table.values.first
    after = f2.table.values.first
    diff = before - after
    puts "before #{before.round(8)} - after #{after.round(8)} = #{diff.round(8)}"
    diff.round(8)
end