# Bases
abstract type AbstractBasis end

struct Material
    scale::Vector{Float64}
    bias::Vector{Float64}
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
end
Metadata(file::String)::Metadata = JSON3.read(file, Metadata)
StructTypes.StructType(::Type{Metadata}) = StructTypes.Struct()

include("bases/PTM.jl")

function readplanes!(buffer::AbstractArray{T,3}, file::String)::Nothing where T <: Real
    # Load plane into view of N×H×W array.
    buffer .= reinterpret(reshape, T, JpegTurbo.jpeg_decode(RGB{T}, file))
    return nothing
end

function readplanes!(buffer::Array{T,3}, files::Vector{String})::Nothing where T <: Real
    # Iterate over planes, loading slices into an array along the first dimension.
    @inbounds for (n, file) in enumerate(files)
        nslices = (3n - 2):3n # Take 3 slices at a time.
        readplanes!(view(buffer, nslices, :, :), file)
    end
end

"""
    loaddir(basis::Type{T}, dir::String)::T where T <: AbstractBasis

Load a directory into a relightable image basis.
"""
function loaddir(Basis::Type{T}, dir::String)::Tuple{AbstractMatrix,T} where T <: AbstractBasis
    # Glob list of plane files in directory.
    base, planes... = glob("plane_*.jpg", dir)
    spec = joinpath(dir, "info.json") |> i -> Metadata(i)
    buffer = Array{Float64, 3}(undef, (spec.nplanes-3, spec.height, spec.width))
    readplanes!(buffer, planes) # Read planes into buffer.
    
    return (JpegTurbo.jpeg_decode(base), Basis(buffer, spec.materials...))
end
