from lex_py import tokens, MAX_LIM
from functions import *

tokens = tokens[:-3]
rpn = ""
res = 0
zero_div = False
no_inv = False
precedence = (
    ('left', 'ADD', 'SUB'),
    ('left', 'MUL', 'DIV'),
    ('right', 'NEG'),
    ('nonassoc', 'POW')
)

def p_line_expr(p):
    'line : exp ENDL'
    global rpn, zero_div, no_inv
    print(rpn)
    print(f"Wynik:   {p[1]}")
    rpn = ""
    zero_div = False
    no_inv = False

def p_line_error(p):
    'line : error ENDL'
    global rpn, zero_div, no_inv
    if zero_div:
        print("Błąd: dzielenie przez 0")
    if no_inv:
        print("Błąd: inwersja nie istnieje")
    else:
        print("Błąd: zła składnia")
    rpn = ""
    zero_div = False
    no_inv = False


def p_number_pos(p):
    'number : NUM'
    p[0] = p[1] % MAX_LIM

def p_number_neg(p):
    'number : SUB number %prec NEG'
    p[0] = negat(-p[2], MAX_LIM)


def p_exp_number_pos(p):
    'exponent_number : NUM'
    p[0] = p[1] % (MAX_LIM - 1)

def p_exp_number_neg(p):
    'exponent_number : SUB number %prec NEG'
    p[0] = negat(-p[2], MAX_LIM - 1)


def p_expr_number(p):
    'exp : number'
    global rpn
    rpn += f"{p[1]} "
    p[0] = p[1]

def p_expr_paren_neg(p):
    'exp : SUB LPAREN exp RPAREN %prec NEG'
    global rpn
    rpn += "~ "
    p[0] = negat(-p[3], MAX_LIM)

def p_expr_neg(p):
    'exp : SUB exp'
    global rpn
    rpn += "neg "
    p[0] = negat(-p[2], MAX_LIM)

def p_expr_paren(p):
    'exp : LPAREN exp RPAREN'
    p[0] = p[2]

def p_expr_add(p):
    'exp : exp ADD exp'
    global rpn
    rpn += "+ "
    p[0] = add(p[1], p[3], MAX_LIM)

def p_expr_sub(p):
    'exp : exp SUB exp'
    global rpn
    rpn += "- "
    p[0] = sub(p[1], p[3], MAX_LIM)

def p_expr_mul(p):
    'exp : exp MUL exp'
    global rpn
    rpn += "* "
    p[0] = mult(p[1], p[3], MAX_LIM)

def p_expr_pow(p):
    'exp : exp POW exponent'
    global rpn
    rpn += "^ "
    p[0] = power(p[1], p[3], MAX_LIM)

def p_expr_div(p):
    'exp : exp DIV exp'
    global rpn
    if p[3] == 0:
        global zero_div
        zero_div = True
        raise SyntaxError
    else:
        res = divide(p[1], p[3], MAX_LIM)
        if(res == -1):
            global no_inv
            no_inv = True
            raise SyntaxError
        else:
            rpn += "/ "
            p[0] = res


def p_exp_number(p):
    'exponent : exponent_number'
    global rpn
    rpn += f"{p[1]} "
    p[0] = p[1]

def p_exp_paren(p):
    'exponent : LPAREN exponent RPAREN'
    p[0] = p[2]

def p_exp_paren_neg(p):
    'exponent : SUB LPAREN exponent RPAREN %prec NEG'
    global rpn
    rpn += "~ "
    p[0] = negat(-p[3], MAX_LIM - 1)

def p_exp_add(p):
    'exponent : exponent ADD exponent'
    global rpn
    rpn += "+ "
    p[0] = add(p[1], p[3], MAX_LIM - 1)

def p_exp_sub(p):
    'exponent : exponent SUB exponent'
    global rpn
    rpn += "- "
    p[0] = sub(p[1], p[3], MAX_LIM - 1)

def p_exp_mul(p):
    'exponent : exponent MUL exponent'
    global rpn
    rpn += "* "
    p[0] = mult(p[1], p[3], MAX_LIM - 1)

def p_exp_div(p):
    'exponent : exponent DIV exponent'
    global rpn
    if p[3] == 0:
        global zero_div
        zero_div = True
        raise SyntaxError
    else:
        res = divide(p[1], p[3], MAX_LIM - 1)
        if(res == -1):
            global no_inv
            no_inv = True
            raise SyntaxError
        else:
            rpn += "/ "
            p[0] = res


def p_error(p):
    pass