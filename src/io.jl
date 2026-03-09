import FileIO
import ImageCore
using Chain
import JSON3
using Glob

include("types/Relightable.jl")
include("utils.jl")

function loaddir(dir::String, Basis::Type{T}) where T <: AbstractBasis
    contents = readdir(dir; join=true)
    plane_files = filter(it -> endswith(it, ".jpg"), contents)

    metadata = JSON3.read(joinpath(dir, "info.json"), Metadata)
    planes = readplanes(dir)

    dequantised = @chain plane_files begin
        map(readplanes, _)
        cat(_...; dims=1)
        dequantise(metadata.materials[1])
    end

    n_planes = metadata.nplanes
    n_rgb = 3

    rgb = dequantised[1:n_rgb, :, :]
    planes = dequantised[n_rgb+1:n_planes, :, :]

    return Relightable(rgb, planes, metadata)
end
