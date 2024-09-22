#!/usr/bin/env -S julia --project=~/git/WannierPlots.jl
using Wannier
using WannierPlots

qe = WannierIO.read_qe_xml("aiida.xml")
kpi, w90 = read_w90_band("aiida", qe.recip_lattice)

shift_fermi = true
fig = plot_band_diff(kpi, qe.eigenvalues, w90; qe.fermi_energy, shift_fermi)
display(fig)

using PlotlyJS
yrange = [-2, 2]
shift_fermi || (yrange .+= qe.fermi_energy)
fig.plot.layout.fields[:yaxis][:range] = yrange
fig.plot.layout.fields[:title] = attr(;
    # text="DFT@PBE vs W90@HSE",
    text="DFT@PBE vs W90@PBE",
    x=0.5, xanchor="center",
    y=0.92, yanchor="bottom",
)
PlotlyJS.savefig(fig, "banddiff.svg"; width=500, height=600)
