import FileIO
import ImageCore
using Chain
import JSON3

include("types.jl")
include("utils.jl")

function parse_plane(path::String)::Array{Float64,3}
    @chain path begin
        FileIO.load
        ImageCore.channelview
        @. Float64
    end
end


function loaddir(dir::String, B::Type{T}) where T <: Basis
    contents = readdir(dir; join=true)
    plane_files = filter(it -> endswith(it, ".jpg"), contents)
    info_file = @chain filter(it -> contains(it, "info.json"), contents) first

    spec = @chain info_file begin
        read(String)
        JSON3.read(B)
    end

    dequantised = @chain plane_files begin
        map(parse_plane, _)
        cat(_...; dims=1)
        dequant(spec.materials[1])
    end

    n_planes = spec.nplanes
    n_rgb = 3

    rgb = dequantised[1:n_rgb, :, :]
    planes = dequantised[n_rgb+1:n_planes, :, :]

    return Relightable(rgb, planes, spec)
end
