import shutil
import os

folder_path = 'results'

# Sprawdź, czy folder istnieje
if os.path.exists(folder_path):
    # Przejrzyj podfoldery
    for subfolder in os.listdir(folder_path):
        subfolder_path = os.path.join(folder_path, subfolder)

        # Sprawdź, czy element to podfolder
        if os.path.isdir(subfolder_path):
            # Usuń zawartość podfoldera
            shutil.rmtree(subfolder_path)
            # Utwórz nowy, pusty podfolder
            os.makedirs(subfolder_path)
else:
    # Jeśli folder nie istnieje, utwórz go
    os.makedirs(folder_path)

print(f"Zawartość podfolderów w {folder_path} została usunięta.")