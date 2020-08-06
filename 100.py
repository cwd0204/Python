
k_list = [0] * 100
k_list[0] = 1

for i in range(1,100):
	k_list[i] = k_list[i-1]+i

print('100 刀最多切 %d块' %k_list[99])
