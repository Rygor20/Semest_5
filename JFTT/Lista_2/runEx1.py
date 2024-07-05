import os
import subprocess

main_path = 'files/ex1'

shas = {
    'l2z1a.r1.txt': "e59f438239f81b6fd7dd0f1c002c60a047272f95",
    'l2z1a.r2.txt': "aa3308bb60cd4063fe569c04e80439f946001fe9",
    'l2z1b.r1.txt': "36e80c27bcad0f91eb316eed58267b64dd7c4620",
    'l2z1b.r2.txt': "5b89c3050be0fd7f20da33f611bb414d8776d5f8",
    'l2z1a.txt': "697f8828b672c9748b6676779a2683790284b8c4",
    'l2z1b.txt': "4d56cb131dc3fc38324ef1fbd1f24a71dfa17819"
}


if os.path.exists(main_path) and os.path.isdir(main_path):
    for subdir in os.listdir(main_path):
        cata_path = os.path.join(main_path, subdir)

        if os.path.isdir(cata_path):
            for plik in os.listdir(cata_path):
                file_path = os.path.join(cata_path, plik)
                sha_result = subprocess.run(['sha1sum', file_path], capture_output=True, text=True)
                if plik in shas and shas[plik] in sha_result.stdout:
                    print(f'File: {plik} - correct sha1sum result')
                else:
                    print(f'File: {plik} - incorrect sha1sum result')

        else:
            print(f'{subdir} not a catalog')

else:
    print(f'Path {main_path} do not exists or is not a catalog')


def check_result():
    ex1_result = subprocess.run(['sha1sum', "answers/zad1_ans.txt"], capture_output=True, text=True)
    if ex1_result.stdout.split()[0] in shas.values():
        found_key = None

        for key, val in shas.items():
            if val == ex1_result.stdout.split()[0]:
                found_key = key
                break
        
        print(f'Exercise 1 result matches file: {found_key}\n')

print()
subprocess.run(['./zad1', "files/ex1/input_zad1/l2z1a.txt"])
check_result()

subprocess.run(['./zad1', "files/ex1/input_zad1/l2z1b.txt"])
check_result()