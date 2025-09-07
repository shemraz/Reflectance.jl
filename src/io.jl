import FileIO
import ImageCore
using Chain: @chain as @>
import JSON

include("types.jl")
include("transform.jl")

function parse_plane(path)::Array{Float64,3}
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
            info[:materials],
            info[:quality]
        )
    end
end

function loaddir(dir::String)
    # TODO: Test case, assert length of 1D == nplanes
    contents = readdir(dir; join=true)

    spec = @> filter(it -> contains(it, "info.json"), contents) begin
        first
        JSON.parsefile(; dicttype=Dict{Symbol,Any})
        match_basis
    end
    planes = @> filter(it -> endswith(it, ".jpg"), contents) begin
        @. parse_plane
        cat(_...; dims=1)
        dequant(spec.materials[1])
    end
    base = planes[1:3, :, :]
    return Relightable(base, planes[4:end, :, :], spec)
end
