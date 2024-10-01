#!/usr/bin/env julia
using WannierIO
# path: WannierDatasets/datasets/Fe_collinear

Au = read_amn("Fe_up.amn")
Ad = read_amn("Fe_dn.amn")
nb_u, nw_u = size(Au[1])
nb_d, nw_d = size(Ad[1])
A = map(Au, Ad) do u, d
        a = zeros(eltype(u), nb_u+nb_d, nw_u+nw_d)
        a[1:nb_u, 1:nw_u] = u
        a[nb_u+1:end, nw_u+1:end] = d
        a
    end

Mu, kpb_k, kpb_G = read_mmn("Fe_up.mmn")
Md = read_mmn("Fe_up.mmn")[1]
M = map(Mu, Md) do u, d
        map(u, d) do ub, db
            m = zeros(eltype(ub), nb_u+nb_d, nb_u+nb_d)
            m[1:nb_u, 1:nb_u] .= ub
            m[nb_u+1:end, nb_u+1:end] .= db
            m
        end
    end

Eu = read_eig("Fe_up.eig")
Ed = read_eig("Fe_dn.eig")
E = map(Eu, Ed) do eu, ed
        [eu; ed]
    end

# I need to sort eig in ascending order
P = map(E) do e
    sortperm(e)
end
println(eachindex(A))
for ik in eachindex(A)
    A[ik] .= A[ik][P[ik], :]
    E[ik] .= E[ik][P[ik]]
    for ib in eachindex(M[ik])
        M[ik][ib] .= M[ik][ib][P[ik], P[kpb_k[ik][ib]]]
    end
end

write_amn("Fe.amn", A)
write_mmn("Fe.mmn", M, kpb_k, kpb_G)
write_eig("Fe.eig", E)
