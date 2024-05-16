import os

pattern=3 # valid option: 0, 1, 2, 3
LENGTH=0 # Length of the pat
path='./dat/P'+str(pattern)

cmd_file=os.path.join(path, 'cmd'+str(pattern)+'.dat')
index_file=os.path.join(path, 'index'+str(pattern)+'.dat')
pat_file=os.path.join(path, 'pat'+str(pattern)+'.dat')
value_file=os.path.join(path, 'value'+str(pattern)+'.dat')

def read_dat(cmd_file, index_file, pat_file, value_file):
    with open(cmd_file, 'r') as file:
        cmd=file.readlines()
        cmd=[line.rstrip('\n') for line in cmd]

    with open(index_file, 'r') as file:
        index=file.readlines()
        index=[line.rstrip('\n') for line in index]

    with open(pat_file, 'r') as file:
        pat=file.readlines()
        pat=[line.rstrip('\n') for line in pat]

    with open(value_file, 'r') as file:
        value=file.readlines()
        value=[line.rstrip('\n') for line in value]

    return cmd, index, pat, value

def max_heapify(A, i):
    l=2*i
    r=2*i+1
    if l<=LENGTH and A[l]>A[i]:
        largest=l
    else:
        largest=i
    if r<=LENGTH and A[r]>A[largest]:
        largest=r
    if largest!=i:
        tmp=A[i]
        A[i]=A[largest]
        A[largest]=tmp
        max_heapify(A, largest)

def build_queue(A):
    for i in range(LENGTH//2, 0, -1):
        max_heapify(A, i)

def extract_max(A):
    global LENGTH
    if LENGTH<1:
        print("heap underflow")
    max=A[1]
    A[1]=A[LENGTH]
    A.pop(LENGTH)
    LENGTH=LENGTH-1
    max_heapify(A, 1)
    return max

def increase_val(A, index, value):
    global LENGTH
    if value<A[index]:
        print('new value is smaller than current value')
    A[index]=value
    # consider the parent node index
    if index%2==0:
        parent_index=index/2
    else:
        parent_index=(index-1)/2
    parent_index=int(parent_index)
    while index>1 and A[parent_index]<A[index]:
        tmp=A[parent_index]
        A[parent_index]=A[index]
        A[index]=tmp
        index=parent_index
        # update parent_index
        if index%2==0:
            parent_index=index/2
        else:
            parent_index=(index-1)/2
        parent_index=int(parent_index)

def insert_data(A, value):
    global LENGTH
    LENGTH=LENGTH+1
    A.append(-10000000)
    increase_val(A, LENGTH, value)


cmd, index, pat, value=read_dat(cmd_file, index_file, pat_file, value_file)
LENGTH=len(pat)
pat=[string.strip() for string in pat]
pat=[int(hex_str, 16) for hex_str in pat]
pat.insert(0, 10000)

value=[string.strip() for string in value]
value=[int(hex_str, 16) for hex_str in value]

index = [int(binary, 10) for binary in index]

print(f'before: {pat}')

idx=0
for command in cmd:
    if command=='000':
        build_queue(pat)
        # print(f'build queue: {pat}')
    elif command=='001':
        maximum=extract_max(pat)
        # print(f'extracted max: {maximum}')
        # print(f'extract: {pat}')
    elif command=='010':
        increase_val(pat, index[idx], value[idx])
        # print(f'increase: {index[idx]}/{value[idx]}/{pat}')
    elif command=='011':
        insert_data(pat, value[idx])
        # print(f'insert: {value[idx]}/{pat}')
    elif command=='100':
        print(f'after: {pat}')
    else:
        print("unrecognized command")
    idx+=1


