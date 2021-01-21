#!/usr/bin/env python3

DATA_DIR = '../01_data'
DEBUG = True
INPUT_FILE = 'input.txt'

def part1(vals):
    print("========== PART 1 ==========")
    val_count = len(vals)
    pairs = [ (vals[i], vals[j])
              for i in range(0, val_count)
              for j in range(0, i)
              if vals[i] + vals[j] == 2020
            ]
    assert(len(pairs) == 1)
    print(f"pairs={pairs}")
    (x, y) = pairs[0]
    print(f"Product={x * y}")

def part2(vals):
    print("========== PART 2 ==========")
    val_count = len(vals)
    trips = [ (vals[i], vals[j], vals[k])
              for i in range(0, val_count)
              for j in range(0, i)
              for k in range(0, j)
              if vals[i] + vals[j] + vals[k] == 2020
            ]
    assert(len(trips) == 1)
    print(f"trips={trips}")
    (x, y, z) = trips[0]
    print(f"Product={x * y * z}")


with open(f'{DATA_DIR}/{INPUT_FILE}') as f:
    lines = f.readlines()
    vals = [int(line.strip()) for line in lines]
    part1(vals)
    part2(vals)
