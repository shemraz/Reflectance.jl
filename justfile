jl:
    julia --project=. -e "using Revise; using Reflectance" --interactive
inst:
    julia --project=. -e "import Pkg; Pkg.instantiate()"
test:
    julia --project=. --interactive -e "import Pkg; Pkg.test()"
