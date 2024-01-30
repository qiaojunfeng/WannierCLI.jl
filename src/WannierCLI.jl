module WannierCLI
using Printf
using Comonicon
using Wannier

# file IO
include("cli/truncate.jl")

# Wannierization
# include("max_localize.jl")
# include("disentangle.jl")
# include("parallel_transport.jl")
# include("opt_rotate.jl")
# include("split_wannierize.jl")

# interpolation
include("cli/band.jl")
include("cli/fermi_surface.jl")
include("cli/fermi_energy.jl")

"""
A collection of covenience commands to use `Wannier.jl` in CLI.
"""
@main

end
