# Reflectance.jl
module Reflectance

import JSON3, JpegTurbo
using ImageCore, Glob, StructTypes

## Submodules
### Core
include("Core.jl")
export AbstractBasis
export loaddir

### Bases
include("bases/PTM.jl")
export PTM
export dequantise!, dequantize!

### Rendering methods
include("Render.jl")
export light

end
