require_relative 'factor'

OC = Factor.new(["OC"],[
    0.75,
    1 - 0.75])
Fraud = Factor.new(["Fraud", "Trav"], [
    0.01,
    0.004,
    1 - 0.01,
    1 - 0.004])
Trav = Factor.new(["Trav"], [
    0.05,
    1 - 0.05])
FP = Factor.new(["FP", "Fraud", "Trav"], [
    0.90,
    0.10,
    0.90,
    0.01,
    1 - 0.90,
    1 - 0.10,
    1 - 0.90,
    1 - 0.01])
IP = Factor.new(["IP", "OC", "Fraud"], [
    0.02,
    0.01,
    0.011,
    0.001,
    1 - 0.02,
    1 - 0.01,
    1 - 0.011,
    1 - 0.001])
CRP = Factor.new(["CRP", "OC"], [
    0.10,
    0.001,
    1 - 0.10,
    1 - 0.001])
Utility = Factor.new(["Block", "Fraud"], [
    0.0,
    -10.0,
    -1000.0,
    5.0])

queryVars = ["Fraud"]
ordering = ["Trav", "FP", "IP", "OC", "CRP"]
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]

# Question 2b Prior
puts "\r\n====== Question 2b prior: Jon Snow's Credit Company"
evidences = {}
result_2b_1 = inference(factors, queryVars, ordering, evidences)
print_summary(result_2b_1, evidences)

# Question 2b Posterior
puts "\r\n====== Question 2b posterior: Nerd makes foreign purchase offline"
evidences = {"FP" => 1, "IP" => 0, "CRP" => 1}
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]
result_2b_2 = inference(factors, queryVars, ordering, evidences)
print_summary(result_2b_2, evidences)

# Question 2c
puts "\r\n====== Question 2c: Jon Snow Co. verfies his client is tripping out"
evidences = {"FP" => 1, "IP" => 0, "CRP" => 1, "Trav" => 1}
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]
result_2c = inference(factors, queryVars, ordering, evidences)
print_summary(result_2c, evidences)
diff = print_change(result_2b_2, result_2c)
puts "After calling we are #{diff * 100} % more confident"

# Question 2d
puts "\r\n====== Question 2d: Jon Snow's traitor"
evidences = {"IP" => 1}
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]
result_2d_1 = inference(factors, queryVars, ordering, evidences)
puts "Before infiltration:"
print_summary(result_2d_1, evidences)
evidences = {"Trav" => 0, "IP" => 1, "CRP" => 1, "FP" => 0}
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]
result_2d_2 = inference(factors, queryVars, ordering, evidences)
puts "After infiltration:"
print_summary(result_2d_2, evidences)
diff = print_change(result_2d_2, result_2d_1)
puts "After preparing to steal, chance of getting caught #{diff * 100}%"

# Question 3b
evidences = {"FP" => 1, "IP" => 0, "CRP" => 1}
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]
fraud = inference(factors, queryVars, ordering, evidences)
result = sumout(multiply(fraud, Utility), "Fraud")
puts "\r\n====== Question 3b: Block nerd's $1000 foreign purchase made offline?"
print_summary(result, evidences)

# Question 3c
evidences = {"FP" => 1, "IP" => 0, "CRP" => 1, "Trav" => 1}
factors = [Fraud.clone, Trav.clone, FP.clone, IP.clone, CRP.clone, OC.clone]
fraud = inference(factors, queryVars, ordering, evidences)
result = sumout(multiply(fraud, Utility), "Fraud")
puts "\r\n====== Question 3c: Block same transaction knowing he's travelling?"
print_summary(result, evidences)
