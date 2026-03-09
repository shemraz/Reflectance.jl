using FixedPointNumbers
using Glob

function load_plane(file::String)::Array{N0f8,3}
    FileIO.load(file) |> ImageCore.channelview
end

function cat₁(slices::Array{N0f8,3}...)::Array{N0f8,3}
    cat(slices...; dims = 1)
end

function readplanes(dir::String)::Array{N0f8,3}
    mapfoldl(load_plane, cat₁, glob("*.jpg", dir))
end

"""
    dequantise(planes::Array{Float64,3}, materials::Dict{Symbol, Any})::Array{Float64,3}

Dequantise an array of coefficients.
"""
function dequantise(planes::Array{N0f8,3}, materials::Dict{Symbol,Vector{N0f8}})::Array{N0f8,3}
    scale = reshape(materials[:scale], (:, 1, 1))
    bias = reshape(materials[:bias], (:, 1, 1))
    return @. (planes - bias) * scale
end
