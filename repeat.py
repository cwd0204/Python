i, j, k = 0, 0 ,0
count = 0

for i in range(21):
	for j in range(51):
		k = 100 - 5 * i - 2*j
		if k >= 0 :
			count += 1
print('count = ',count)


i, j, k = 0, 0 ,0
count = 0

for i in range(21):
    print('i is', i)
    for j in range(51):
        print('j is',j)
        k = 100 - 5 *i - 2*j
        print('k is', k)
print('done')


i = 1
while i % 3: 
    print(i, end = ' ')
    if i >= 10:
        break
    i += 1