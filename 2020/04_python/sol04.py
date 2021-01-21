#!/usr/bin/env python3

import re


DATA_DIR = '../04_data'
DEBUG = False
INPUT_FILE = 'input.txt'
# INPUT_FILE = 'input_test.txt'

known_fields = set('byr iyr eyr hgt hcl ecl pid cid'.split(' '))
valid_ecls = set('amb blu brn gry grn hzl oth'.split(' '))

year_pat       = re.compile('\d\d\d\d$')
height_pat     = re.compile('(\d+)(\w+)$')
hair_color_pat = re.compile('#[0-9a-f]{6}$')
pid_pat        = re.compile('\d{9}$')

do_strip = lambda s: s.strip()

def add_pass_fields(pass_dict, line):
     fields = line.split(' ')
     for field in fields:
         key, val = field.split(':')
         assert(key in known_fields)
         pass_dict[key] = val
     return pass_dict

def dprint(*args, **kwargs):
    if DEBUG:
        print(*args, **kwargs)

def is_valid1(pass_dict):
    diff = known_fields.difference(pass_dict.keys())
    result = len(diff) == 0 or (len(diff) == 1 and 'cid' in diff)
    if result:
        pass
    else:
        dprint(f'Invalid: Missing fields: {diff}')
    return result

def is_valid2(pass_dict):
    diff = known_fields.difference(pass_dict.keys())
    are_fields_valid = len(diff) == 0 or (len(diff) == 1 and 'cid' in diff)
    if not are_fields_valid:
        diff.discard('cid')
        dprint(f'==> Missing fields: {diff}')
        return False

    if not is_valid_byr(pass_dict['byr']): dprint('==> Bad byr'); return False
    if not is_valid_iyr(pass_dict['iyr']): dprint('==> Bad iyr'); return False
    if not is_valid_eyr(pass_dict['eyr']): dprint('==> Bad eyr'); return False
    if not is_valid_hgt(pass_dict['hgt']): dprint('==> Bad hgt'); return False
    if not is_valid_hcl(pass_dict['hcl']): dprint('==> Bad hcl'); return False
    if not is_valid_ecl(pass_dict['ecl']): dprint('==> Bad ecl'); return False
    if not is_valid_pid(pass_dict['pid']): dprint('==> Bad pid'); return False
    # dprint(f'Valid credentials!')
    return True

def is_valid_byr(val):
    if not re.match(year_pat, val):
        dprint(f'byr pattern mismatch: {val}')
        return False

    assert(val[0] != '0')

    byr = int(val)
    result = 1920 <= byr <= 2002
    if not result:
        dprint(f'byr out of range: {val}')
    return result

def is_valid_iyr(val):
    if not re.match(year_pat, val):
        dprint(f'iyr pattern mismatch: {val}')
        return False

    assert(val[0] != '0')

    iyr = int(val)
    result = 2010 <= iyr <= 2020
    if not result:
        dprint(f'iyr out of range: {val}')
    return result

def is_valid_eyr(val):
    if not re.match(year_pat, val):
        dprint(f'eyr pattern mismatch: {val}')
        return False

    assert(val[0] != '0')

    eyr = int(val)
    result = 2020 <= eyr <= 2030
    if not result:
        dprint(f'eyr out of range: {val}')
    return result

def is_valid_hgt(val):
    m = re.match(height_pat, val)
    if not m:
        dprint(f'hgt pattern mismatch: {val}')
        return False

    assert(m.group(1)[0] != '0')
    hgt = int(m.group(1))
    units = m.group(2)
    if units == '':
        dprint(f'Missing hgt units: {val}')
        return False

    is_correct_units = units == 'cm' or units == 'in'
    if not is_correct_units:
        dprint(f'Bad hgt units: {val}')
        return False

    result = (units == 'cm' and 150 <= hgt <= 193) or (units == 'in' and 59 <= hgt <= 76)
    if not result:
        dprint(f'Bad hgt range: {val}')
    return result

def is_valid_hcl(val):
    m = re.match(hair_color_pat, val)
    if not m:
        dprint(f'hcl pattern mismatch: {val}')
        return False

    return True

def is_valid_ecl(val):
    result = val in valid_ecls
    if not result:
        dprint(f'ecl not in list: {val}')
        return False

    return True

def is_valid_pid(val):
    m = re.match(pid_pat, val)
    if not m:
        dprint(f'pid pattern mismatch: {val}')
        return False

    return True

def print_line(line):
    if DEBUG:
        if line:
            dprint(f'line={line}')
        else:
            dprint('===== ===== ===== ===== =====')

def part1(lines):
    print("========== PART 1 ==========")
    valid_count = 0
    invalid_count = 0
    pass_dict = {}

    for line in lines:
        if line == '':
            if is_valid1(pass_dict):
                valid_count += 1
            else:
                invalid_count += 1
            pass_dict = {}
        else:
            pass_dict = add_pass_fields(pass_dict, line)
        print_line(line)

    if is_valid1(pass_dict):
        valid_count += 1
    else:
        invalid_count += 1
    print(f'valid_count={valid_count} (invalid_count={invalid_count})')

def part2(lines):
    print("========== PART 2 ==========")
    valid_count = 0
    invalid_count = 0
    line_num = 0
    pass_dict = {}

    for line in lines:
        if line == '':
            if is_valid2(pass_dict):
                dprint(f'Valid credentials for line_num={line_num}')
                valid_count += 1
            else:
                invalid_count += 1
            # print(f'========================================')
            pass_dict = {}
            line_num += 1
        else:
            pass_dict = add_pass_fields(pass_dict, line)
        # print_line(line)

    if is_valid2(pass_dict):
        dprint(f'VALID: ord={line_num}')
        valid_count += 1
    else:
        invalid_count += 1
    print(f'valid_count={valid_count} (invalid_count={invalid_count})')


if __name__ == '__main__':
    valid_count = 0
    invalid_count = 0

    with open(f'{DATA_DIR}/{INPUT_FILE}') as f:
        lines = list(map(do_strip, f.readlines()))
        part1(lines)
        print()
        part2(lines)
