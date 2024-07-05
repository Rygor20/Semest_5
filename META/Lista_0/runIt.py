import subprocess

for i in range(1, 11):
    nazwa_pliku = f'case{i}.txt'
    sciezka_do_skryptu = f'Data/{nazwa_pliku}'
    subprocess.run(['python3', 'MST.py', sciezka_do_skryptu])
