# Bases
abstract type AbstractBasis end

include("bases/PTM.jl")
include("bases/HSH.jl")
include("bases/RBF.jl")
include("bases/BLN.jl")
include("bases/YCC.jl")

function load_channels(file::String)::Array{Float64,3}
    # Load plane into 1×H×W array.
    FileIO.load(file) |> ImageCore.channelview
end

function getplanes(
    files::Vector{String} # A list of JPEGs.
 )::Array{Float64,3}
    cat(
        load_channels.(files)...;
        dims=1
    )
end

function load(
    basis::Type{T},
      dir::String
)::T where T <: AbstractBasis
    # Glob list of plane files in directory.
    files::Vector{String} = glob("plane_*.jpg", dir)
    model::Array{Float64,3} = getplanes(files) # Load planes into an array.
    # Read metadata from `info.json`.
    metadata = joinpath(dir, "info.json") |> JSON3.read
    basis(model, metadata)
end
