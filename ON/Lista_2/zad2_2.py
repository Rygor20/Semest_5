#Igor Misiek
#Obliczenia naukowe - Lista 2

import numpy as np
import matplotlib.pyplot as plt

#Zapis funkcji rekurencyjnej
def f(x):
    return np.exp(x) * np.log(1 + np.exp(-x))

#Ustalenie wartości dla osi x i y
x = np.linspace(-50, 50, 1000)
y = f(x)

plt.plot(x, y)
plt.xlabel('x')
plt.ylabel('f(x)')
plt.grid(True)

plt.savefig("python_plot.png")
