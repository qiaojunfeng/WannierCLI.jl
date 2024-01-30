# Example usage: ./compute_num_electrons.jl aiida e 1e13
using Dates
using WannierIO
using LinearAlgebra
using DelimitedFiles

"""
Compute Fermi energy with given number of electrons and doping concentration for
a 2D material.

The vacuum layer is assumed along the z-axis of the crystal structure.

# Requires
- `prefix_tb.dat`/`prefix_wsvec.dat` files for Wannier interpolation of energy eigenvalues
- `prefix.win` file for excluded bands during Wannierization
- QE output `prefix.xml` file for parsing the number of electrons

# Args
- `prefix`: prefix of e.g. `aiida_tb.dat` and `aiida_wsvec.dat`

# Options
- `--dopetype`: electron or hole, `e` or `h`
- `--concentration`: Number of carrier per cm^2.
- `--nkx`: number of kpoints along x direction for Wannier interpolation
- `--nky`: number of kpoints along y direction for Wannier interpolation
- `--nkz`: number of kpoints along z direction for Wannier interpolation
- `--prefactor`: 1 for SOC calculation, 2 for spinless
"""
@cast function fermi_energy(
    prefix::String;
    dopetype::String="",
    concentration::Float64=0.0,
    nkx::Int=48,
    nky::Int=48,
    nkz::Int=1,
    prefactor::Int=2,
)
    println("Started on ", Dates.now())

    win = WannierIO.read_win(prefix * ".win")
    n_exclude_bands = length(get(win, :exclude_bands, []))

    ANG_TO_CM = 1e-8
    lattice = win.unit_cell_cart
    a1, a2, a3 = eachcol(lattice)
    @assert iszero([a1[3], a2[3], a3[1], a3[2]]) "vaccum layer must be along the z-axis"
    area = norm(a1 × a2) * ANG_TO_CM^2

    tb = Wannier.read_w90_tb(prefix)
    # or get lattice from TB file
    # lattice = real_lattice(tb.hamiltonian)

    xml = WannierIO.read_qe_xml(prefix * ".xml")
    n_electrons_pristine = round(Int, xml.n_electrons)
    # number of valence for the Wannier TB model
    n_electrons_valence = n_electrons_pristine - prefactor * n_exclude_bands

    n_electrons_doped = concentration * area
    if dopetype == "e"
        n_electrons = n_electrons_valence + n_electrons_doped
    elseif dopetype == "h"
        n_electrons = n_electrons_valence - n_electrons_doped
    else
        isempty(dopetype) || error("dopetype must be `e` or `h` or empty")
        n_electrons = n_electrons_valence
    end

    @show dopetype concentration area
    @show n_electrons_doped n_electrons_valence n_electrons
    @printf("QE scf Fermi Energy: %.8f\n", xml.fermi_energy)

    smearing_type = "fd"
    if smearing_type == "none"
        smearing = Wannier.NoneSmearing()
    elseif smearing_type == "fermi-dirac" || smearing_type == "fd"
        smearing = Wannier.FermiDiracSmearing()
    elseif smearing_type == "marzari-vanderbilt" || smearing_type == "cold"
        smearing = Wannier.ColdSmearing()
    else
        error("Unknown smearing type: $smearing_type")
    end
    @show smearing_type

    # unit conversion, constants from QE/Modules/Constants.f90
    K_BOLTZMANN_SI = 1.380649E-23  # J K^-1
    ELECTRONVOLT_SI = 1.602176634E-19
    HARTREE_SI = 4.3597447222071E-18
    RYDBERG_SI = HARTREE_SI / 2.0
    BOHR_TO_ANG = 0.529177210903
    # width = 0.03
    # kBT = width * RYDBERG_SI / ELECTRONVOLT_SI
    kBT = 300 * K_BOLTZMANN_SI / ELECTRONVOLT_SI  # 300K to eV

    println("Grid size: $nkx x $nky x $nkz")
    kgrid = [nkx, nky, nkz]

    interp = Wannier.HamiltonianInterpolator(tb.hamiltonian)
    # eigenvalues, _ = interp(kpoints)
    εF = Wannier.compute_fermi_energy(
        kgrid,
        interp,
        n_electrons,
        kBT,
        smearing;
        prefactor,
        tol_n_electrons=1e-6,
        tol_εF=1e-3,
        max_refine=10,
        #width_εF=1,
    )
    println("Fermi energy with doping: $εF")

    # shc = readdlm(seedname * "-shc-fermiscan.dat", skipstart=1)

    # shc_fermi_arg = argmin(abs.(shc[:, 2] .- εF))
    # shc_fermi = shc[shc_fermi_arg, 3]
    # @show shc_fermi_arg
    # println("# shc_fermi (3D unit)  c_length (cm)")
    # println("  $shc_fermi           $c")
end
