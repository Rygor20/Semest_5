from ply import lex, yacc

import lex_py
import bison_py


def main():
    lexer = lex.lex(module=lex_py)
    parser = yacc.yacc(module=bison_py)
    while True:
        text = ""
        while True:
            try:
                text += input()
            except EOFError:
                return
            text += '\n'
            if not text.endswith('\\\n'):
                break
        parser.parse(text, lexer=lexer)


if __name__ == "__main__":
    main()