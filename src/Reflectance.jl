# Reflectance.jl
module Reflectance

using Glob, ImageCore, StructTypes
import JSON3, JpegTurbo

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
