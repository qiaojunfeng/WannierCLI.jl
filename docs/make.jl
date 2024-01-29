using WannierCLI
using Documenter

DocMeta.setdocmeta!(WannierCLI, :DocTestSetup, :(using WannierCLI); recursive=true)

makedocs(;
    modules=[WannierCLI],
    authors="Junfeng Qiao <qiaojunfeng@outlook.com> and contributors",
    sitename="WannierCLI.jl",
    format=Documenter.HTML(;
        canonical="https://qiaojunfeng.github.io/WannierCLI.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/qiaojunfeng/WannierCLI.jl",
    devbranch="main",
)
