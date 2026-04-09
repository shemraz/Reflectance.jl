# Core.jl

## Core types used by all relightables.

### Supertype of all bases.
abstract type AbstractBasis end

### Used to dequantise planes.
struct Material
    scale::Vector{Float64}
    bias::Vector{Float64}
    range::Union{Vector{Float64}, Nothing}
end

struct Metadata
    width::Int
    height::Int
    format::String
    type::String
    colorspace::String
    nplanes::Int
    quality::Int
    materials::Vector{Material}
    lights::Union{Vector{Float16},Nothing}
    basis::Union{Vector{UInt8},Nothing}
end

### Data in `info.json` is read directly into a Metadata struct.
Metadata(file::String)::Metadata = JSON3.read(file, Metadata)

StructTypes.StructType(::Type{Metadata}) = StructTypes.Struct()

## IO methods used to read image data into bases.

function readplanes!(buffer::AbstractArray{T, 3}, file::String, scale::Real)::Nothing where {T <: Real}
    # Load plane into view of N×H×W array.
    buffer .= reinterpret(reshape, T, JpegTurbo.jpeg_decode(RGB{T}, file; scale_ratio = scale))
    return nothing
end

function readplanes!(buffer::AbstractArray{T, 3}, files::Vector{String}, scale::Real)::Nothing where {T <: Real}
    # Iterate over planes, loading slices into an array along the first dimension.
    return @inbounds for (n, file) in enumerate(files)
        nslices = (3n - 2):3n # Take 3 slices at a time.
        readplanes!(view(buffer, nslices, :, :), file, scale)
    end
end

"""
    dequantise!(A::Array{T,3}, scale::AbstractVector{<:Real}, bias::AbstractVector{<:Real}) where T <: Real

Dequantise coefficients in-place by subtracting bias and applying scale.

Each plane `i` of `A` is transformed as `(A[i,:,:] .- bias[i]) .* scale[i]`.
Vectors `scale` and `bias` must have length equal to the first dimension of `A`.

See also [`dequantize!`](@dequantize!) for the American-English spelling alias.
"""
function dequantise!(A::Array{T, 3}, scale::AbstractVector{<:Real}, bias::AbstractVector{<:Real})::Array{Float64, 3} where {T <: Real}
    # Iterate over first dimension of A.
    @views for i in axes(A, 1)
        A[i, :, :] .-= bias[i] # Subtract bias.
        A[i, :, :] .*= scale[i] # Multiply 2-D plane by corresponding scalar.
    end
    return A
end

function dequantise!(A::AbstractArray{T, 3}, range::AbstractVector{<:Real})::Array{Float64, 3} where {T <: Real}
    offset = 127.0
    # Iterate over first dimension of A, which is length N + 1.
    @views for i in axes(A, 1)
        A[i, :, :] .-= offset
        A[i, :, :] ./= range[i] # Divide 2-D plane by corresponding scalar.
    end
    return A
end

dequantize!::Function = dequantise! # Alias for American-English spelling.

### API
"""
    loaddir(Basis::Type{T}, dir::String; scale::Real = 1)::Tuple{AbstractMatrix,T} where T <: AbstractBasis

Load a base image and basis model from a [Relight](https://github.com/cnr-isti-vclab/relight) directory structure.

Parses `info.json` for metadata, decodes the base image, and loads plane data into
a buffer. The buffer and material properties are passed to the a constructor for
basis-specific processing.

# Arguments
- `Basis`: Concrete subtype of `AbstractBasis` to construct (e.g., [`PTM`](@PTM)).
- `dir`: Directory path containing `info.json`, base image, and plane files.
- `scale`: Optional spatial downsampling ratio for height and width (default 1).

# Returns
A tuple containing:
- The base image as a `Matrix{<:AbstractRGB}`.
- The constructed `Basis` instance populated with all non-RGB planes.

See also [`PTM`](@PTM).
"""
function loaddir(Basis::Type{T}, dir::String; scale::Real = 1)::Tuple{AbstractMatrix, T} where {T <: AbstractBasis}
    # Glob list of plane files in directory.
    base, planes... = glob("plane_*.jpg", dir)
    spec = joinpath(dir, "info.json") |> i -> Metadata(i)
    height::Int, width::Int = map([spec.height, spec.width]) do x
        x *= scale
        ceil(x)
    end
    buffer = Array{Float64, 3}(undef, (spec.nplanes - 3, height, width))
    readplanes!(buffer, planes, scale) # Read planes into buffer.

    return (JpegTurbo.jpeg_decode(RGB{Float64}, base; scale_ratio = scale), Basis(buffer, spec.materials...))
end
