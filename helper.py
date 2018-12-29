#!usr/bin/env python3
# -*- coding: utf-8 -*-

basic_ops = ['+', '-', '*', '/', '^']
extend_ops = ['exp', 'ln', 'log2', 'log10', 'log', 'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'sigmoid', 'relu',
              'sign']


def prefix_to_infix(prefix_expression):
    if prefix_expression[0] == '(':
        prefix_expression = prefix_expression[1:-1]
    start_with_extend_op = False
    (start_with_basic_op, prefix_op) = is_start_with_basic_op(prefix_expression)
    if not start_with_basic_op:
        (start_with_extend_op, prefix_op) = is_start_with_extend_op(prefix_expression)

    if start_with_basic_op:
        if is_binary_expr(prefix_expression):
            (part1, part2) = decompose_binary_prefix(prefix_op, prefix_expression)
            if (part1[0] == '+' or part1[0] == '-') and is_binary_expr(part1):
                part1 = '(' + part1 + ')'
            if (part2[0] == '+' or part2[0] == '-') and is_binary_expr(part2):
                part2 = '(' + part2 + ')'
            return '%s %s %s' % (prefix_to_infix(part1), prefix_op, prefix_to_infix(part2))
        else:
            part = decompose_unary_prefix(prefix_op, prefix_expression)
            return '%s%s' % (prefix_op, prefix_to_infix(part))
    elif start_with_extend_op:
        if prefix_op == 'log10':
            (part1, part2) = decompose_binary_prefix(prefix_op, prefix_expression)
            return '%s(%s, %s)' % (prefix_op, prefix_to_infix(part1), prefix_to_infix(part2))
        else:
            part = decompose_unary_prefix(prefix_op, prefix_expression)
            return '%s(%s)' % (prefix_op, prefix_to_infix(part))
    else:
        return prefix_expression


def is_start_with_basic_op(prefix_expression):
    for op in basic_ops:
        if prefix_expression.startswith(op):
            return (True, op)
    return (False, None)


def is_start_with_extend_op(prefix_expression):
    for op in extend_ops:
        if prefix_expression.startswith(op):
            return (True, op)
    return (False, None)


def is_binary_expr(expr):
    body = expr[2:-1]
    if (body.find(',') <= 0):
        return False
    else:
        for index in find_all_comma(body):
            (part1, part2) = (body[:index], body[index + 1:])
            if (match_brace(part1) and match_brace(part2)):
                return True
    return False


def find_all_comma(expr):
    indexs = []
    last_index = -1
    while expr[last_index + 1:].find(',') >= 0:
        last_index = expr[last_index + 1:].find(',') + last_index + 1
        indexs.append(last_index)
    return indexs


def match_brace(expr):
    brace_count = 0
    for char in expr:
        if char == '(':
            brace_count += 1
        elif char == ')':
            brace_count -= 1
    return brace_count == 0


def decompose_binary_prefix(op, prefix_expression):
    body = prefix_expression[len(op) + 1:-1]
    for index in find_all_comma(body):
        (part1, part2) = (body[:index], body[index + 1:])
        if (match_brace(part1) and match_brace(part2)):
            return (part1, part2)
    raise SyntaxError('not match!')


def decompose_unary_prefix(op, prefix_expression):
    return prefix_expression[len(op) + 1:-1]
