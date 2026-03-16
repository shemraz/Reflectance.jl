module Reflectance

import FileIO, FixedPointNumbers
using ImageCore
import JSON3
using Glob, Chain, InteractiveUtils

# Submodules
include("Core.jl")
include("Render.jl")

# Public types
export AbstractBasis
export PTM

# Public methods
export relightable
export render

end
