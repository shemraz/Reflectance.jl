set shell := [ "nu", "-c" ]

# Aliases
alias j := jl
alias e := edit
alias i := info

default:
  @just --choose

jl:
    julia --project=. -e "using Revise; using Reflectance" --interactive

inst:
    julia --project=. -e "import Pkg; Pkg.instantiate()"

test:
    julia --project=. --interactive -e "import Pkg; Pkg.test()"

info:
    open --raw "test/data/ptm/info.json"

@edit:
    helix (ls src/**/*.jl | input list | get name)
