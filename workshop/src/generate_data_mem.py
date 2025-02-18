import random

nof_mem_positions = 15
data_width = 8

numbers = [random.randint(0, 2**8) for _ in range(nof_mem_positions)]

# Convert to 8-bit binary strings and write to file
with open('./mem_data.txt', 'w') as f:
    for num in numbers:
        # Convert to binary and remove '0b' prefix, then pad to 8 bits
        binary = format(num, '08b')
        f.write(f'{binary}\n')
