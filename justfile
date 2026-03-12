set shell := [ "nu", "-c" ]

default:
  @just --choose

jl:
    julia --project=. -e "using Revise; using Reflectance" --interactive

inst:
    julia --project=. -e "import Pkg; Pkg.instantiate()"

test:
    julia --project=. --interactive -e "import Pkg; Pkg.test()"

info:
    open --raw "test/ptm/info.json"

alias i := info
