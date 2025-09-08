import FileIO
import ImageCore
using Chain: @chain as @>
import JSON

include("types.jl")
include("utils.jl")

function parse_plane(path::String)::Array{Float64,3}
    @> path begin
        FileIO.load
        ImageCore.channelview
        @. Float64
    end
end

function match_basis(info::Dict{Symbol,Any})::Basis
    if info[:type] == "ptm"
        return PTM(
            info[:width],
            info[:height],
            info[:format],
            info[:type],
            info[:colorspace],
            info[:nplanes],
            convert(Vector{Dict{Symbol, Vector{Float64}}}, info[:materials]),
            info[:quality]
        )
    end
    throw(ArgumentError("Unsupported basis type: $(info[:type])"))
end

function loaddir(dir::String)
    # TODO: Test case, assert length of 1D == nplanes
    contents = readdir(dir; join=true)
    plane_files = filter(it -> endswith(it, ".jpg"), contents)
    info_file = filter(it -> contains(it, "info.json"), contents)

    spec = @> info_file begin
        first
        JSON.parsefile(; dicttype=Dict{Symbol,Any})
        match_basis
    end

    dequantised = @> plane_files begin
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
