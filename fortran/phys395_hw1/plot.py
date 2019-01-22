#!/usr/bin/env python3

import csv
import matplotlib.pyplot as plt
import numpy as np

plt.style.use('dark_background')

def read_csv(filename):
    rows = []

    with open(filename, 'r') as f:
        reader = csv.reader(f, delimiter=',')
        header = tuple(map(str.rstrip, next(reader)))
        for line in reader:
            rows.append(tuple(map(float, line)))

    return header, rows

def plot_csv(csv_filename, out_filename, ylim, title):
    header, rows = read_csv(csv_filename)
    series = list(map(np.array, zip(*rows)))
    x, f, f10, f100 = series
    it = zip(header, series)
    _, _ = next(it)

    plt.figure()
    for i, (label, data) in enumerate(it):
        plt.plot(x, data, label=label, zorder=-i)

    plt.legend()
    plt.ylim(ylim)
    plt.title(title)
    plt.savefig(out_filename, dpi=300)

    err10  = np.abs(f - f10)
    err100 = np.abs(f - f100)

    with np.warnings.catch_warnings():
        np.warnings.filterwarnings('ignore')
        print('{:12} | {:12.3f} | {:12.3f} | {:12.3f} | {:12.3f}'.format(
            out_filename.lstrip('plot_').rstrip('.png'),
            np.max(err10),
            x[np.argmax(err10)],
            np.max(err100),
            x[np.argmax(err100)]))

def main():
    print(
        '\nThe max and argmax of the error is provided below for both'
        '\nChebyshev polynomial with 10 terms and'
        '\nChebyshev polynomial with 100 terms.\n')
    print('{:12} | {:>12} | {:>12} | {:>12} | {:>12}'.format('Name', 'max err10', 'argmax err10', 'max err100', 'argmax err100'))

    plot_csv(
        csv_filename='results_f_uniform.csv',
        out_filename='plot_f_uniform.png',
        ylim=(0.0, 1.0),
        title=r'$f(x)$ evaluated for $x_i$ uniformly spaced')

    plot_csv(
        csv_filename='results_df_uniform.csv',
        out_filename='plot_df_uniform.png',
        ylim=(-4.0, 4.0),
        title=r'$\frac{d}{dx}f(x)$ evaluated for $x_i$ uniformly spaced')

    plot_csv(
        csv_filename='results_f_zeros.csv',
        out_filename='plot_f_zeros.png',
        ylim=(0.0, 1.0),
        title=r'$f(x)$ evaluated for $x_i$ at zeros of $T_n(x)$')

    plot_csv(
        csv_filename='results_df_zeros.csv',
        out_filename='plot_df_zeros.png',
        ylim=(-4.0, 4.0),
        title=r'$\frac{d}{dx}f(x)$ evaluated for $x_i$ at zeros of $T_n(x)$')

    print()

main()

# TODO plot out error
# TODO figure out why results are backwards for "_zeros"
