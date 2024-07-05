import sys
import io


def buildTransitionTable(pattern):
    m = len(pattern)
    occuring = set(pattern)
    transitionTable = {}
    for char in occuring:
        transitionTable[char] = [0] * (m + 1)

    transitionTable[pattern[0]][0] = 1

    x = 0
    for j in range(1, m + 1):
        for char in occuring:
            transitionTable[char][j] = transitionTable[char][x]

        if j < m:
            #set next step for match in sequence
            transitionTable[pattern[j]][j] = j + 1
            #set variable for setting return index
            x = transitionTable[pattern[j]][x]

    return transitionTable


def finiteAutomaton(pattern, text):
    m = len(pattern)
    n = len(text)
    transitions = buildTransitionTable(pattern)
    print("Transition Table:")
    for char, row in transitions.items():
        print(f"{char}: {row}")
    occurrences = []

    q = 0
    for i in range(n):
        if text[i] in transitions:
            q = transitions[text[i]][q]
        else:
            q = 0

        if q == m:
            occurrences.append(i - m + 1)

    return occurrences


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Correct usage: python3 FA.py <pattern> <file_name>")
        sys.exit(1)

    pattern = sys.argv[1]
    fileName = sys.argv[2]

    with io.open(fileName, mode='r', encoding="utf-8") as file:
        text = file.read()

    occurrences = finiteAutomaton(pattern, text)

    if occurrences:
        result = ""
        for entry in occurrences:
            result += str(entry) + " "
        print("Pattern found at positions: " + result)
    else:
        print('Pattern not found!')