using WannierCLI

# See possible options by
# julia --project deps/build.jl -h

# If you want to use a different depot path, e.g., `~/wjl`, run the following
# in the Wannier.jl directory:
# JULIA_DEPOT_PATH=~/wjl julia --project -e 'using Pkg; Pkg.instantiate()'
# JULIA_DEPOT_PATH=~/wjl julia --project deps/build.jl

WannierCLI.comonicon_install()
