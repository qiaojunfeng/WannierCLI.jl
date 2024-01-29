# WannierCLI

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://qiaojunfeng.github.io/WannierCLI.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://qiaojunfeng.github.io/WannierCLI.jl/dev/)
[![Build Status](https://github.com/qiaojunfeng/WannierCLI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/qiaojunfeng/WannierCLI.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/qiaojunfeng/WannierCLI.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/qiaojunfeng/WannierCLI.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Why do we need this package?

When using the code in practice, some times we want to quickly run a
Wannierization or interpolation of band structure and save the results to a
file, without the need of launching julia shell and typing boilerplate code,
e.g., loading/saving files.

These kind of routine tasks are better done in a command line interface, to
provide some pre-defined workflows, which can also help encode conventional
wisdom of how to use the code, e.g., choosing proper kpoint grids for
interpolating Fermi surface, etc.

This package installs a CLI command `wjl` in `~/.julia/bin`, somewhat mimicking
the behavior of the `wannier90.x` executable. However, the goal of this package
is **NOT** to:
- write general-enough CLI commands that can handle all the possible use cases
- provide a compatible interface to `wannier90.x` that parses the `win` file
    and runs the code in the respective modes

But **rather** to provide:
- some quick commands for the most common use cases
- templates for users to quickly copy & modify to suit their needs

That is, if the user needs to do some complicated tasks, it is better to
directly write them in a julia script to call the functions in `Wannier.jl`,
rather than designing a complicated input file format, e.g., `win` file or any
other formats, to control the behavior of the code--this is where julia's
interactivity shines than a compiled language.

In addition, the separation of this package from the `Wannier.jl` also improves
the developer experience of the `Wannier.jl` package, by reducing the compilation
time as well as avoiding name clashes^1.

## Installation

```julia
julia> ]  # enter the package manager
(@v1.10) pkg> add WannierCLI
(@v1.10) pkg> build
```

[^1]: If the code of `WannierCLI.jl` were inside the `Wannier.jl` package, I had
    to use a different name for the CLI subcommands, because `Comonicon.jl`
    would possibly return wrong docstring when there are multiple functions having
    the same name, e.g., `disentangle`.
