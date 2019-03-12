#!/usr/bin/env python

import csv
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
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

def plot_time_series(csv_filename, out_filename, ylim=None, title=None):
    styles = [
        {'color': '#00ffff', 'linewidth': 2},
        {'color': '#ffff00', 'linewidth': 2},
        {'color': '#ff00ff', 'linewidth': 2}]
    header, rows = read_csv(csv_filename)
    series = list(map(np.array, zip(*rows)))
    t, th1, th2, energy = series

    fig, axes = plt.subplots(nrows=2, sharex=True)
    plot_multiple(axes[0], t, zip(styles[:2], header[1:], series[1:]))
    plot_multiple(axes[1], t, [(styles[2], header[3], series[3])])

    axes[0].set_title(title)
    axes[0].set_ylim(ylim)
    axes[0].legend(framealpha=0.9)
    axes[1].legend(framealpha=0.9)
    fig.savefig(out_filename, dpi=300)

def plot_trajectory(csv_filename, out_filename, xlim=None, ylim=None, title=None):
    header, rows = read_csv(csv_filename)
    series = list(map(np.array, zip(*rows)))
    t, th1, th2, energy = series

    l1, l2 = 1.0, 1.0
    x1 =  l1 * np.sin(th1)
    y1 = -l1 * np.cos(th1)
    x2 =  l2 * np.sin(th2) + x1
    y2 = -l2 * np.cos(th2) + y1

    cmaps = [plt.cm.viridis, plt.cm.magma]
    legend_elements = [
        plt.Line2D([0], [0], color=cmaps[0](0.7), lw=2, label=header[1]),
        plt.Line2D([0], [0], color=cmaps[1](0.7), lw=2, label=header[2])]

    fig, ax = plt.subplots(nrows=1)
    plot_cmapped(fig, ax, t, x2, y2, cmaps[1])
    plot_cmapped(fig, ax, t, x1, y1, cmaps[0])

    ax.set_title(title)
    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    ax.set_aspect('equal')
    ax.legend(handles=legend_elements, framealpha=0.9)
    fig.savefig(out_filename, dpi=300)

def plot_cmapped(fig, ax, t, x, y, cmap='viridis'):
    points = np.array([x, y]).T.reshape(-1, 1, 2)
    segments = np.concatenate([points[:-1], points[1:]], axis=1)
    # t = np.linspace(0.0, 1.0, x.shape[0])
    norm = plt.Normalize(t.min(), t.max())
    lc = LineCollection(segments, cmap=cmap, norm=norm)
    lc.set_array(t)
    lc.set_linewidth(2)
    line = ax.add_collection(lc)
    fig.colorbar(line, ax=ax)

def plot_multiple(ax, x, it):
    for i, (style, label, data) in enumerate(it):
        mask = ~np.isnan(data)
        x_ = x[mask]
        data = data[mask]
        ax.plot(x_, data, label=label, zorder=i, **style)

def main():
    plot_time_series(
        csv_filename='results.csv',
        out_filename='plot_time_series.svg',
        title=r'Double pendulum')

    plot_trajectory(
        csv_filename='results.csv',
        out_filename='plot_trajectory.svg',
        title=r'Double pendulum',
		xlim=(-2.0, 2.0),
		ylim=(-2.0, 2.0))

main()
