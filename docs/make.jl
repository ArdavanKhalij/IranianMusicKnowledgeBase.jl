using IranianMusicKnowledgeBase
using Documenter

DocMeta.setdocmeta!(IranianMusicKnowledgeBase, :DocTestSetup, :(using IranianMusicKnowledgeBase); recursive=true)

makedocs(;
    modules=[IranianMusicKnowledgeBase],
    authors="Ardavan Khalij",
    repo="https://github.com/ArdavanKhalij/IranianMusicKnowledgeBase.jl/blob/{commit}{path}#{line}",
    sitename="IranianMusicKnowledgeBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ArdavanKhalij.github.io/IranianMusicKnowledgeBase.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ArdavanKhalij/IranianMusicKnowledgeBase.jl",
    devbranch="main",
)
