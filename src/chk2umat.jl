#!/usr/bin/env -S julia --project
# Installation: julia --project=. -e 'using Pkg; Pkg.instantiate()'
# Run: ./chk2umat.jl EXAMPLE.chk
using WannierIO

length(ARGS) == 1 || error("Need one argument for chk filename")
filename = ARGS[1]

chk = read_chk(filename)
U = get_U(chk)

outfilename = basename(filename) * ".u_dis.mat"
WannierIO.write_u_mat(outfilename, U, chk.kpoints)
