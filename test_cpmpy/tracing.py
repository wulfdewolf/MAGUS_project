import numpy as np
from cpmpy import *

input = np.array([ 1,  2,  3, 1,  2,  3, 3,  1])
subalignment_start = np.array([0, 3, 6, 8])

output = intvar(1,input.size,  shape=input.shape, name="output")

model = Model()

for a in range(subalignment_start.size - 1):
    for n in range(subalignment_start[a], subalignment_start[a+1]-1):
        model += (output[n] < output[n+1])


for n1 in range(input.size - 1):
    for n2 in range(n1+1, input.size):
        print(str(n1) + " = " + str(input[n1]) +  " , " + str(n2) + " = " + str(input[n2])  )
        if input[n1] != input[n2]:
            model += output[n1] != output[n2]

# Check following two possibilities for performance:
model.minimize(max([output[subalignment_start[a]-1] for a in range(1, subalignment_start.size)]))
# model.minimize(max(output))


print(model)

if model.solve():
    print(output.value())
else:
    print("No solution found")