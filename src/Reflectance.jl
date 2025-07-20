module Reflectance

using Chain: @chain as @>
using Base.Iterators

struct Meta
    version::String
    format::String
    width::Int
    height::Int
    scale::Vector{Float64}
    bias::Vector{Int}
end

struct PTM
    header::Meta
    luma::Array{UInt8,3}
    chroma::Array{UInt8,3}
end

function header!(io::IO)::Vector{Any}
    @> eachline(io) begin
        first(_, 6)
        vcat(
            first(_, 2),
            parse.(Int, _[3:4]),
            map(_[5:end]) do x
                parse.(Float64,
                    filter(!=(""), split(x, " "))
                )
            end
        )
    end
end

function pixels!(io::IO, width::Int, height::Int, planes::Int)::AbstractArray
    chroma = zeros(UInt8, planes, width, height)

    for y in 1:height
        row = Vector{UInt8}(undef, width * planes)
        readbytes!(io, row)
        index = 1

        for x in 1:width
            for p in 1:planes
                chroma[p, x, y] = row[index]
                index += 1
            end
        end
    end
    return chroma
end

function ptm(filename::AbstractString)::PTM
    open(filename, "r") do io
        let spec = Meta(header!(io)...)
            PTM(
                spec,
                pixels!(
                    io,
                    spec.width,
                    spec.height,
                    length(spec.scale)
                ),
                pixels!(
                    io,
                    spec.width,
                    spec.height,
                    3
                )
            )
        end
    end
end

include("transform.jl")

export PTM, Meta, luminance

end
