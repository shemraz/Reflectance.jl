module Reflectance

using Chain: @chain as @>
using Base.Iterators

struct Meta
    version::String
    format::String
    width::Int32
    height::Int32
    scale::Vector{Float64}
    bias::Vector{Int32}
end

struct PTM
    header::Meta
    luma::Array{Int32, 3}
    chroma::Array{Int32, 3}
end

function get_header!(io::IO)::Vector{Any}
    @> eachline(io) begin
        first(_, 6)
        vcat(
            first(_, 2),
            parse.(Int32, _[3:4]),
            map(_[5:end]) do x
                parse.(Float64,
                    filter(!=(""), split(x, " "))
                )
            end
        )
    end
end

function get_texels!(io::IO, dims::Vector{Int}) ::AbstractArray
    arr = zeros(UInt8, dims...)
    readbytes!(io, arr)
    return [arr[:, :, 1:6], arr[:, :, 7:9]]
end

function ptm(filename::AbstractString) ::PTM
    open(filename, "r") do io
        let spec = Meta(get_header!(io)...)
            PTM(
                spec,
                get_texels!(
                    io,
                    [
                        spec.height,
                        spec.width,
                        length(spec.scale)+3,
                    ]
                )...
            )
        end
    end
end

export PTM, Meta

end
