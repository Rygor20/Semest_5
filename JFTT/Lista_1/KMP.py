import sys
import io


def computePrefixFunction(pattern):
    m = len(pattern)
    prefixTable = [0] * m
    k = 0

    for q in range(1, m):
        #searching for longest matching correct suffix and prefix
        #it will tell us how many symbols we can "skip"
        while k > 0 and pattern[k] != pattern[q]:
            k = prefixTable[k-1]
        if pattern[k] == pattern[q]:
            k += 1
        prefixTable[q] = k

    return prefixTable


def kmpSearch(pattern, text):
    n = len(text)
    m = len(pattern)
    prefixTable = computePrefixFunction(pattern)
    print("Prefix Table:", prefixTable)
    occurrences = []

    q = 0
    for i in range(n):
        while q > 0 and pattern[q] != text[i]:
            q = prefixTable[q-1]
        if pattern[q] == text[i]:
            q += 1
        if q == m:
            occurrences.append(i - m + 1)
            q = prefixTable[q-1]

    return occurrences


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Correct usage: python3 KMP.py <pattern> <file_name>")
        sys.exit(1)

    pattern = sys.argv[1]
    fileName = sys.argv[2]

    with io.open(fileName, mode='r', encoding="utf-8") as file:
        text = file.read()

    occurrences = kmpSearch(pattern, text)

    if occurrences:
        result = ""
        for entry in occurrences:
            result += str(entry) + " "
        print("Pattern found at positions: " + result)
    else:
        print('Pattern not found!')