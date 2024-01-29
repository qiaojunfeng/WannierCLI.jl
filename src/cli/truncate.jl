"""
Truncate number of bands in `mmn`/`eig`/`unk` files.

# Args

- `prefix`: `prefix.mmn` for `mmn`/`eig` files
- `bands`: indices of bands to be kept, start from 1

# Options

- `--outdir`: dirname for output `mmn`/`eig`. Default is `truncate`

# Flags

- `--unk`: also truncate `unk` files, for plotting WFs
"""
@cast function truncate(
    prefix::String, bands::Int...; outdir::String="truncate", unk::Bool=false
)
    # tuple to vector
    keepbands = collect(bands)
    truncate_w90(prefix, keepbands, outdir, unk)
    return nothing
end
