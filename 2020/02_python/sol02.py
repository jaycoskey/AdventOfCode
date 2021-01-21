#!/usr/bin/env python3

DATA_DIR = '../02_data'
INPUT_FILE = 'input.txt'
# INPUT_FILE = 'input_test.txt'

import re

line_regex = re.compile("(\d+)-(\d+) (\w): (\w+)")

def parse_pwd_line(line):
    m = re.search(line_regex, line)
    mgrp = lambda n: m.group(n)
    re_min,  re_max = int(mgrp(1)), int(mgrp(2))
    re_char, pwd    = mgrp(3), mgrp(4)
    # pwd = pwd.strip()
    #    re_count_str, re_char = re_str.split()
    #    re_min_str, re_max_str = re_count_str.split('-')
    return (re_min, re_max, re_char, pwd)

def part1(lines):
    print("========== PART 1 ==========")
    valid_count = 0
    for line in lines:
        (re_min, re_max, re_char, pwd) = parse_pwd_line(line)
        pwd_regex = re.compile(re_char)
        re_count_found = len(pwd_regex.findall(pwd))  # Could have used filter & len
        if re_count_found >= re_min and re_count_found <= re_max:
            valid_count += 1
    print(f'valid count={valid_count}') 

def part2(lines):
    print("========== PART 2 ==========")
    valid_count = 0
    for line in lines:
        (re_min, re_max, re_char, pwd) = parse_pwd_line(line)
        is_at_1 = pwd[re_min - 1] == re_char
        is_at_2 = pwd[re_max - 1] == re_char

        if (is_at_1 or is_at_2) and not (is_at_1 and is_at_2):
        # if is_at_1 ^ is_at_2:
            # print(f'line={line}')
            valid_count += 1
    print(f'valid count={valid_count}') 


if __name__ == "__main__":
    with open(f'{DATA_DIR}/{INPUT_FILE}') as f:
        do_strip = lambda s: s.strip()
        lines = list(map(do_strip, f.readlines()))
        part1(lines)
        part2(lines)
