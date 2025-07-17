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
    texels::AbstractArray
end

function header(io::IO) ::Vector{Any}
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

# TODO: Fix shape of returned array
function texels(io::IO)
    arr = zeros(UInt8, 3361*2970*9)
    readbytes!(io, arr)
    return arr
end

function readptm(
    filename::AbstractString
)
    open(filename, "r") do io
        PTM(
            Meta(header(io)...),
            collect(texels(io))
        )
    end
end

end
