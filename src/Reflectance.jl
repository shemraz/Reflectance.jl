module Reflectance

import FileIO, FixedPointNumbers, JSON3
using ImageCore, Glob, InteractiveUtils

# Submodules
include("Core.jl")
include("Render.jl")

# Public types
export AbstractBasis
export PTM

# Public methods
export Relightable
export render

end
