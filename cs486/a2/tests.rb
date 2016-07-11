
# # Example AIMA p. 527
# fAB = Factor.new("AB", [0.3,0.7,0.9,0.1])
# fBC = Factor.new("BC", [0.2,0.8,0.6,0.4])
# tmp = multiply(fAB, fBC) # expect [0.06, 0.24, 0.42, 0.28, 0.18, 0.72, 0.06, 0.04]
# sumout(tmp, "A") # expect [0.24, 0.96, 0.48, 0.32]

# # Example pointwise multiply on wikipedia
# fpq = Factor.new("pq", [0.1,0.3,0.5,0.7])
# fqr = Factor.new("qr", [0.2,0.4,0.6,0.8])
# tmp = multiply(fpq, fqr) # expect [0.02, 0.04, 0.18, 0.24, 0.1, 0.2, 0.42, 0.56]
# sumout(tmp, "q") # expect

# # Example from lecture8 p. 12
# fab = Factor.new("AB",[0.9,0.1,0.4,0.6])
# fbc = Factor.new("BC",[0.7,0.3,0.8,0.2])
# tmp = multiply(fab, fbc) # expect [0.63, 0.27, 0.08, 0.02, 0.28, 0.12, 0.48, 0.12]

# # p. 13
# sumout(fab, "A") # expect [1.3, 0.7]

# # p. 14
# restrict(fab, "A", 1) # expect [0.9, 0.1]

# # p. 16 A->B->C BN
# f1 = Factor.new("A",[0.9,0.1])
# f2 = Factor.new("AB",[0.9,0.1,0.4,0.6])
# f3 = Factor.new("BC",[0.7,0.3,0.2,0.8])
# f4 = multiply(f1,f2) # expect [0.81, 0.09, 0.04, 0.06]
# f4 = sumout(f4, "A") # expect [0.85, 0.15]
# f5 = multiply(f4, f3) # expect [0.595, 0.255, 0.03, 0.12]
# f5 = sumout(f5, "B") # expect [0.625, 0.375]

# # Example from A Variable Elimination Algorithm for Belief Networks
# f_c = Factor.new("C", [0.5,0.5])
# f_cs = Factor.new("CS",[0.1, 0.9, 0.5, 0.5])
# f_cr1 = Factor.new("CR",[0.8, 0.2,0.2,0.8])
# f_srw = Factor.new("SRW", [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])

# f_sr = restrict(f_srw, "W", 1) # expect [0.99, 0.9, 0.9, 0.0]
# f_cr2 = sumout(multiply(f_cs, f_sr), "S") # expect [0.909, 0.09, 0.945, 0.45]

# f_X = multiply(f_c, f_cr1)
# f_Y = multiply(f_X, f_cr2)
# f_r = sumout(f_Y, "C") # expect [0.4581, 0.189]
# normalize(f_r) # expect[0.7079, 0.2921]

# # Example lecture8 p. 16 A->B->C
# f1 = Factor.new("A",[0.9,0.1])
# f2 = Factor.new("AB",[0.9,0.1,0.4,0.6])
# f3 = Factor.new("BC",[0.7,0.3,0.2,0.8])
# factors = [f1, f2, f3]
# queryVars = ["C"]
# ordering = ["A", "B"]
# evidences = {}
# inference(factors, queryVars, ordering, evidences) # expect [0.625, 0.375]


# # Example AIMA p. 512 Alarm, B,E -> A -> J, M
# b = Factor.new("B",[0.001, 1-0.001])
# e = Factor.new("E",[0.002, 1-0.002])
# a = Factor.new("BE",[0.95, 0.94, 0.29, 0.001])
# j = Factor.new("A",[0.9, 0.05])
# m = Factor.new("A",[0.7, 0.01])

# factors = [b, e, a, j, m]
# queryVars = ["B"]
# ordering = []
# evidences = {"J" => 1, "M" => 1}
# inference(factors, queryVars, ordering, evidences)






