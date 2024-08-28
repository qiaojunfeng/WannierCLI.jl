using TOML: parsefile

"""
Split valence and conduction Wannier functions.

Usually start from a Wannierization of valence+conduction bands,
then this command split MLWFs into two subgroups.

# Args

- `seedname`: seedname for `win`/`amn`/`mmn`/`eig` files

# Options

- `--nval`: number of valence WFs. Default is `n_wann ÷ 2`
- `--outdir-val`: dirname for output valence `amn`/`mmn`/`eig`. Default is `val`
- `--outdir-cond`: dirname for output conduction `amn`/`mmn`/`eig`. Default is `cond`
- `--config`: config file for `splitvc` command, e.g.
    ```toml
    [groups]
    indices = [ [ 1, 2,], [ 3, 4, 5, 6,], [ 7, 8,], ]
    outdirs = [ "val_1", "val_2", "cond_3",]
    ```

# Flags

- `--run-dis`: read `amn` and run disentangle first, otherwise read `chk` to
    get unitary matrices from `n_bands` to `n_wann`
- `--run-optrot`: max localize w.r.t. single unitary matrix after parallel transport.
    Should further reduce the spread and much closer to the true max localization.
- `--run-maxloc`: run a final max localize w.r.t. all kpoints.
    Should reach the true max localization.
- `--rot-unk`: generate `unk` files for valence and conduction, for plotting WFs
- `--gen-win`: generate `win` files for valence and conduction
- `--binary`: write `amn`/`mmn`/`eig`/`unk` in Fortran binary format
"""
@cast function mrwf(
    seedname::String;
    nval::Int = 0,
    outdir_val::String = "val",
    outdir_cond::String = "cond",
    config::String = "",
    run_dis::Bool = false,
    run_optrot::Bool = false,
    run_maxloc::Bool = false,
    rot_unk::Bool = false,
    gen_win::Bool = false,
    binary::Bool = false,
)
    # the valcond MLWFs
    if run_dis
        # Read initial gauges from amn file
        model = read_w90(seedname)
        model.gauges .= disentangle(model)
    else
        # Read MLWF gauge from chk file
        model = read_w90_with_chk(seedname)
    end
    if gen_win
        win = read_win(joinpath(seedname, ".win"))
        win = Dict(pairs(win))
        for k in [
            :num_bands,
            :dis_froz_proj,
            :dis_proj_min,
            :dis_proj_max,
            :dis_win_min,
            :dis_win_max,
            :dis_froz_min,
            :dis_froz_max,
            :auto_projections,
        ]
            pop!(win_i, k, nothing)
        end
        # just write a random projection as a placeholder
        win_i[:projections] = ["random"]
        win_i[:num_iter] = 1000
    end

    if isempty(config)
        (nval != 0) || @error "`nval` not provided"
        @info "number of valence WFs = $nval"
        indices = [1:nval, (nval+1):n_wannier(model)]
        outdirs = [outdir_val, outdir_cond]
    else
        @info "reading config file: $config"
        groups = parsefile(config)["groups"]
        indices = groups["indices"]
        outdirs = groups["outdirs"]
    end
    println("Model will be split into $(length(indices)) groups")
    for (i, idxs) in enumerate(indices)
        println("  Group $i:")
        println("    indices: $(idxs)")
        println("    outdir : $(outdirs[i])")
    end

    # @info "Spread of input model"
    # show(omega(model))
    # println("\n")

    models_Us = split_wannierize(model, indices)

    for (i, (m, U)) in enumerate(models_Us)
        @info "Group $i after parallel transport:" omega(m)
        println("\n")

        if run_optrot
            @info "Run optimal rotation"
            println()
            W = opt_rotate(m)
            m.gauges .= merge_gauge(m.gauges, W)
        end

        if run_maxloc
            @info "Run max localization"
            println()
            m.gauges .= max_localize(m)
        end

        # Write files
        outdir = joinpath(dirname(seedname), outdirs[i])
        mkpath(outdir)
        seedname_i = joinpath(outdir, basename(seedname))
        write_w90(seedname_i, m; binary)

        # prepare win file with correct num_wann
        if gen_win
            win_i[:num_wann] = n_wannier(m)
            write_win("$seedname_i.win"; win_i...)
        end
    end

    # UNK files for plotting WFs
    if rot_unk
        dir = dirname(seedname)
        isempty(dir) && (dir = ".")

        outdirs = [joinpath(dir, odir) for odir in outdirs]
        split_unk(dir, [mU[2] for mU in models_Us], outdirs; binary)
    end

    return nothing
end
