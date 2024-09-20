#!/usr/bin/env -S julia --project=~/git/WannierPlots.jl
using Wannier
using WannierPlots

qe = WannierIO.read_qe_xml("aiida.xml")
kpi, w90 = read_w90_band("aiida", qe.recip_lattice)

fig = plot_band_diff(kpi, qe.eigenvalues, w90; qe.fermi_energy)
display(fig)
