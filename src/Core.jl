# Bases
abstract type AbstractBasis{T,N} end

# TODO:
include("bases/PTM.jl")
## include("bases/HSH.jl")
## include("bases/RBF.jl")
## include("bases/BLN.jl")
## include("bases/YCC.jl")

function readplanes!(buffer::AbstractArray{T,3}, file::String)::Nothing where T <: Real
    # Load plane into view of N×H×W array.
    buffer .= T.(reinterpret(reshape, FixedPointNumbers.N0f8, FileIO.load(file)))
    return nothing
end

function readinfo(dir::String)::JSON3.Object
    # Load metadata as a JSON object.
    file = joinpath(dir, "info.json")
    if !ispath(file)
        throw(ArgumentError("No `info.json` exists at given path: " * file))
    end
    return JSON3.read(file)
end

const Relightable = Tuple{Matrix{AbstractRGB{T}}, B} where T <: Real where B <: AbstractBasis

function planes(Basis::Type{T}, planes::Vector{String}...; dims::Tuple{Int, Int, Int}, materials::Union{Vector{Any}, Nothing})::T where T <: AbstractBasis
    # Glob list of plane files in directory.
    files::Vector{String} = glob("plane_*.jpg", dir)
    info = readinfo(dir)

    if isempty(files)
        throw(ArgumentError("No JPEGs exist at given path: " * dir))
    end

    # Iterate over planes, loading slices into an array along the first dimension.
    buffer = Array{Float32, 3}(undef, (info.nplanes, info.height, info.width))

    @inbounds for (n, file) in enumerate(files)
        nslices = (3n - 2):3n # Take 3 slices at a time.
        readplanes!(view(buffer, nslices, :, :), file)
    end

    return Basis(buffer, materials...)
end

function planes(Basis::Type{T}, planes...; materials::Vector{Any})
