class Factor
    attr_accessor :names
    attr_accessor :table

    def initialize(varnames, values)
    # values expected to be 2^varnames.size in reverse sorted order (1s to 0s)
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
    idx = factor.names.index(variable)

    # remove entries not equal to value
    factor.table = factor.table.delete_if { |k, v| k[ idx ] != value }

    # change key names
    new_table = Hash.new(factor.table.size)
    factor.table.each do |key, value|
        key.delete_at(idx)
        new_table[key] = value
    end
    factor.table = new_table

    # remove variable name
    # factor.names.delete(variable)
end

def multiply(otherFactor)

end


vars = ["S","R","W"]
prob = [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0]
variable = "W"
value = 1
f = Factor.new(vars, prob)
restrict(f, variable, value)
