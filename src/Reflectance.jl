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
    luma::Array{Float64,3}
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
    n = *(width, height, planes)
    raw = Vector{UInt8}(undef, n)
    readbytes!(io, raw)

    @> raw begin
        reshape(planes, width, height)
        permutedims((1, 2, 3))
    end
end

function computecf(texels::Array{UInt8,3}, scale::Vector{Float64}, bias::Vector{Int64})::Array{Float64,3}
    bias_norm = bias ./ 255.0
    coeff(c, σ, β) = (c - β) * σ
    scale3 = reshape(scale, (:, 1, 1))
    bias3 = reshape(bias_norm, (:, 1, 1))
    coeff.(texels, scale3, bias3)
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
                ) |> texels -> computecf(texels, spec.scale, spec.bias),
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

export PTM, Meta, ptm, simulate

end
