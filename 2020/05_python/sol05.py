#!/usr/bin/env python3

DATA_DIR = '../05_data'
INPUT_FILE = 'input_sorted.txt'

def part1(seat_ids):
    print("========== PART 1 ==========")
    print(f'Max sid={sorted(seat_ids)[-1]}')

def part2(seat_ids):
    print("========== PART 2 ==========")
    prev_sid = None
    for sid in seat_ids:
        if prev_sid != None and sid == prev_sid + 2:
            print(f'Missing: {sid - 1}')
            return
        prev_sid = sid

def seat_str2int(seat_str):
    def s2b(c):
        if c == 'B': return 1
        if c == 'F': return 0
        if c == 'L': return 0
        if c == 'R': return 1
    result = sum([2**(9 - k) * s2b(c) for k,c in enumerate(seat_str)])
    return int(result)


if __name__ == '__main__':
    seat_ids = []
    with open(f'{DATA_DIR}/{INPUT_FILE}') as f:
        seat_ids = [seat_str2int(line.strip()) for line in f.readlines()]

    part1(seat_ids)
    print()
    part2(seat_ids)
