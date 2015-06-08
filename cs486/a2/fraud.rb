class Factor
    def initialize(varnames, values)
    # values expected to be 2^varnames.size in reverse sorted order (1s to 0s)
        @names = varnames
        @table = Hash.new(2 ** @names.size)
        assignments(@names.size).each_with_index { |a, i| @table[a] = values[i] }
    end

# names = ["S", "R", "W"]
# values = [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0]
# table = {}
# assignments(names.size).each_with_index { |a, i| table[a] = values[i] }

# variable = "W"
# value = 1
# table.delete_if { |k, v| k[ names.index(variable) ] != value }

# # change key names
# idx = names.index(variable)
# table.delete_if { |k, v| k[ idx ] != value }
# new_table = Hash.new(table.size)
# table.each do |key, value|
#     key.delete_at(idx)
#     puts " ! #{key}"
#     new_table[key] = value
# end
# table = new_table

    def restrict(variable, value)
    # restricts a variable to some value
        raise Error unless @names.include?(variable) && (value == 0 || value == 1)
        idx = @names.index(variable)

        # remove entries not equal to value
        @table.delete_if { |k, v| k[ idx ] != value }

        # change key names
        new_table = Hash.new(@table.size)
        @table.each do |key, value|
            key.delete_at(idx)
            puts " ! #{key}"
            new_table[key] = value
        end
        @table = new_table

        # remove variable name
        @names.delete(variable)
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

vars = ["S","R","W"]
prob = [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0]
f = Factor.new(vars, prob)
f1 = f
f1.restrict("W", 1)
