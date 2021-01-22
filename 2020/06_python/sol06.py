#!/usr/bin/env python3

DATA_DIR = '../06_data'
INPUT_FILE = 'input.txt'
# INPUT_FILE = 'input_test.txt'


def len_intersection(people):
    if len(people) == 1:
        return sum([len(p) for p in people])
    else:
        return len(set.intersection(*people))


if __name__ == '__main__':
    yes_any_counts = []
    yes_all_counts = []

    with open(f'{DATA_DIR}/{INPUT_FILE}') as f:
        groups = f.read().split('\n\n')
        for group in groups:
            yes_any_count = len([c for c in set(group) if c.isalpha()])
            # print(f'yes_any_count = {yes_any_count}')
            yes_any_counts.append(yes_any_count)
            # --------------------
            people = [set(person) for person in group.strip().split('\n')]
            yes_all_count = len_intersection(people)
            yes_all_counts.append(yes_all_count)

    print(f'PART 1: Sum of yes_any_counts = {sum(yes_any_counts)}')
    print(f'PART 2: Sum of yes_all_counts = {sum(yes_all_counts)}')
