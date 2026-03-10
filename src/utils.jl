using FixedPointNumbers
using Glob

#= TODO:
    Need to change types from N0f8 to Float64 because dequantising the array won't
    work on N0f8, which must be between 0.0 and 1.0. Only use N0f8 when rendering
    the output image.
=#
function load_plane!(file::String)::Array{Float64,3}
    # Load plane into 1×H×W array.
    FileIO.load(file) |> ImageCore.channelview
end

function read_planes(
    # dir::String
    files::Vector{String} # A list of JPEGs.
 )::Array{Float64,3}
    model = cat(
        load_plane!.(files)...;
        dims=1
    )
end

function dequantise!(A::Array{Float64,3}, scale::Vector{Float64}, bias::Vector{Float64})::Array{Float64,3}
    # Iterate over planes, where each plane is a height-by-width matrix.
    nplanes, _, _ = size(A)
    for i ∈ 1:nplanes
        A[i,:,:] *= scale[i] # Multiply 2-D plane by corresponding scalar.
        A[i,:,:] .+= bias[i]
    end
    # scale = reshape(materials[:scale], (:, 1, 1))
    # bias = reshape(materials[:bias], (:, 1, 1))
    # return @. (planes - bias) * scale
end

dequantize!::Function = dequantise! # Alias for American-English spelling.
