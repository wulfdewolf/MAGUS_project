import numpy as np
from cpmpy import *

nr_alignments = 3

input = np.array([ 1,  2,  3, 1,  2,  3, 3,  1, 0])
subalignment_start = np.array([0, 3, 6, 9])

nr_variables = input[input != 0].size

output = intvar(1, nr_variables,  shape=input.shape, name="output")

model = Model()


# all variables of the same alignment should be ordered strictly increasing. 
i = 0
for a in range(subalignment_start.size - 1):
    for n in range(subalignment_start[a], subalignment_start[a+1]):
        if input[n] == 0:
            continue
        else:
            for n1 in range(n+1, subalignment_start[a+1]+1):
                if input[n] == 0:
                    continue
                elif n1 == subalignment_start[a+1] :
                    break
                else:
                    model += (output[i] < output[i+1])
                    break
            i += 1

# nodes having different cluster ids in the input, should also have different cluster ids in the output
i = 0
j = 0
for n1 in range(input.size-1):
    if input[n1] == 0:
        continue
    else:
        j = i + 1
        for n2 in range(n1+1, input.size):
            if input[n2] == 0:
                continue
            elif input[n1] != input[n2]: 
                model += output[i] != output[j]
            j += 1
            
    i += 1

# Check following two possibilities for performance:
#model.minimize(max([output[subalignment_start[a]-1] for a in range(1, subalignment_start.size)]))
model.minimize(max(output))

print(model)

if model.solve():
    i = 0
    for n in range(input.size):
        if input[n] != 0:
            input[n] = output[i].value()
            i += 1
    print(input)
    
else:
    print("No solution found")