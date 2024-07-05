MAX_LIM = 1234577

tokens = (
    'NUM',
    'ADD',
    'SUB',
    'MUL',
    'DIV',
    'POW',
    'ENDL',
    'LPAREN',
    'RPAREN',
    'COMMENT',
    'LINE_CONT',
    'ERR',
)

def t_NUM(t):
    r'\d+'
    t.value = int(t.value)
    return t

t_ignore = ' \t'
t_ignore_COMMENT = r'^\#(.|\\\n)*\n'
t_ignore_LINE_BREAK = r'\\\n'

t_ADD = r'\+'
t_SUB = r'[-]'
t_MUL = r'\*'
t_DIV = r'[/]'
t_POW = r'\^'
t_ENDL = r'\n'
t_LPAREN = r'\('
t_RPAREN = r'\)'
t_ERR = r'.'

def t_error(t):
    print("err")
    pass