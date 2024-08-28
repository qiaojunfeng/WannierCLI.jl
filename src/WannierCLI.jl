module WannierCLI
using Printf
using Comonicon
using Wannier

# file IO
include("truncate.jl")

# Wannierization
# include("max_localize.jl")
# include("disentangle.jl")
# include("parallel_transport.jl")
# include("opt_rotate.jl")
# include("split_wannierize.jl")

# interpolation
include("band.jl")
include("fermi_surface.jl")
include("fermi_energy.jl")

"""
A collection of covenience commands to use `Wannier.jl` in CLI.
"""
Comonicon.@main

end
