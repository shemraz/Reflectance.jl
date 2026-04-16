# Reflectance.jl
module Reflectance

using Glob, ImageCore, LinearAlgebra, StructTypes
import JSON3, JpegTurbo

## Submodules
### Core
include("Core.jl")
export AbstractBasis
export dequantise!, dequantize!
export loaddir

### Bases
include("bases/PTM.jl")
export PTM
include("bases/RBF.jl")
export RBF

### Rendering methods
include("Render.jl")
export light

end
