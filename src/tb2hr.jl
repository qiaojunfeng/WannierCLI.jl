#!/usr/bin/env -S julia --project=/home/jqiao/git/WannierCLI.jl
using Dates
using Wannier

"""
Convert W90 prefix_tb.dat to prefix_hr.dat format.

Usage:
    julia tb2hr.jl prefix [prefix_new]
"""
function (@main)(args)
    if length(args) ∉ [1, 2]
        error("Only accept one or two arguments")
    end
    prefix = args[1]
    prefix_new = length(args) == 2 ? args[2] : "$(prefix)_new"

    hamiltonian, position = read_w90_tb(prefix)
    write_w90_hr(prefix_new, hamiltonian; skip_wsvec=true)

    println("Job done at ", Dates.now())
end
