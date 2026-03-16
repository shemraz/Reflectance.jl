# Bases
abstract type Basis{T,N} <: AbstractArray{T,N} end

include("bases/PTM.jl")

# TODO:
## include("bases/HSH.jl")
## include("bases/RBF.jl")
## include("bases/BLN.jl")
## include("bases/YCC.jl")

function load_channels!(file::String, buffer::AbstractArray{Float64,3})::Nothing
    # Load plane into view of N×H×W array.
    buffer .= Float64.(reinterpret(reshape, FixedPointNumbers.N0f8, FileIO.load(file)))
    return nothing
end

function load_metadata(dir::String)::JSON3.Object
    # Load metadata as a JSON object.
    joinpath(dir, "info.json") |> JSON3.read
end

function getplanes(
    files::Vector{String},
    dims::NTuple{3,Int}
 )::Array{Float64,3}
    # Iterate over planes, loading channels into an array along the first dimension.
    A = Array{Float64, 3}(undef, dims)

    @inbounds for (n, file) in enumerate(files)
        planes3 = (3n-2):3n
        load_channels!(file, view(A, planes3, :, :))
    end
    return A
end

"""
    relightable(
        basis::Type{T},
          dir::String
    )::T where T <: Basis

TBW
"""
function relightable(
    basis::Type{T},
      dir::String
)::T where T <: Basis
    # Glob list of plane files in directory.
    files::Vector{String} = glob("plane_*.jpg", dir)

    if isempty(files) 
        throw(ArgumentError("No JPEGs exist at given path: " * dir))
    end

    m = load_metadata(dir)
    dims = (m.nplanes, m.height, m.width)
    basis(getplanes(files, dims), m)
end
