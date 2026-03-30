# Bases
abstract type AbstractBasis{T,N} end

include("bases/PTM.jl")

function readplanes!(buffer::AbstractArray{T,3}, file::String)::Nothing where T <: Real
    # Load plane into view of N×H×W array.
    buffer .= T.(reinterpret(reshape, FixedPointNumbers.N0f8, FileIO.load(file)))
    return nothing
end

function readplanes!(buffer::Array{T,3}, files::Vector{String})::Nothing where T <: Real
    # Iterate over planes, loading slices into an array along the first dimension.
    @inbounds for (n, file) in enumerate(files)
        nslices = (3n - 2):3n # Take 3 slices at a time.
        readplanes!(view(buffer, nslices, :, :), file)
    end
end

function readjson(dir::String)::JSON3.Object
    # Load metadata as a JSON object.
    file = joinpath(dir, "info.json")
    if !ispath(file)
        throw(ArgumentError("No `info.json` exists at given path: " * file))
    end
    return JSON3.read(file)
end

const MaterialComponent{T} = Vector{T}

function materials(type::Type{T}, json::JSON3.Object)::AbstractVector{MaterialComponent{T}} where T<: AbstractFloat
    getproperty(json, :materials) |> first |> values |> collect
end

"""
    loaddir(basis::Type{T}, dir::String)::T where T <: AbstractBasis

Load a directory into a relightable image basis.
"""
function loaddir(basis::Type{T}, dir::String)::Tuple{AbstractMatrix,T} where T <: AbstractBasis
    # Glob list of plane files in directory.
    files::Vector{String} = glob("plane_*.jpg", dir)
    if isempty(files)
        throw(ArgumentError("No JPEGs exist at given path: " * dir))
    end
    json = readjson(dir)
    buffer = Array{basis.parameters[1], 3}(undef, (json.nplanes-3, json.height, json.width))
    base, planes... = files
    readplanes!(buffer, planes) # Read planes into buffer.
    base_img = JpegTurbo.jpeg_decode(base)
    return (base_img, basis(buffer, materials(json)...))
end
