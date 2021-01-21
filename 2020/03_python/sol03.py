#!/usr/bin/env python3

DATA_DIR = '../03_data'
INPUT_FILE = 'input.txt'
WIDTH = 31


def print_chart(chart):
    for line in chart:
        line = ''.join(line)
        assert(len(line) == WIDTH)
        print(line)
        # print()

def is_tree(chart, row_num, col_num):
    # print(f'row={row_num}, col={col_num}')
    result = chart[row_num][col_num % WIDTH] == '#'
    # print('1' if result else '0', end='')
    return result

def get_tree_count(chart, step_e, step_s, do_debug=False):
    tree_count = 0

    row_num = 1
    col_num = 1
    while row_num <= len(chart):
        did_hit_tree = is_tree(chart, row_num - 1, col_num - 1)
        if do_debug:
            print(f'(row1,col1)=({row_num},{col_num}): hit_tree={did_hit_tree}')
        if did_hit_tree:
            tree_count += 1
        row_num += step_s
        col_num += step_e
    # print(f'Returning tree_count={tree_count}')
    return tree_count

def part1(chart):
    print("========== PART 1 ==========")
    tree_count = 0
    for row_num in range(1, 1 + len(chart)):
        col_num = 1 + 3 * (row_num - 1)
        if is_tree(chart, row_num - 1, col_num - 1):
            tree_count += 1
    print(f'tree_count={tree_count}')

def part2(chart):
    print("========== PART 2 ==========")
    # tree_count = get_tree_count(chart, 3, 1)
    # print(f'tree_count={tree_count}')

    tc_1_1 = get_tree_count(chart, 1, 1)
    tc_3_1 = get_tree_count(chart, 3, 1)
    tc_5_1 = get_tree_count(chart, 5, 1)
    tc_7_1 = get_tree_count(chart, 7, 1)
    tc_1_2 = get_tree_count(chart, 1, 2)

    product = tc_1_1 * tc_3_1 * tc_5_1 * tc_7_1 * tc_1_2
    print(f'product={product}')


if __name__ == '__main__':
    chart = [[]]
    with open(f'{DATA_DIR}/{INPUT_FILE}') as f:
        chart = [[c for c in line.strip()] for line in f.readlines()]
        WIDTH = len(chart[0])
        # print_chart(chart)

    part1(chart)
    part2(chart)
