using StructTypes

# Bases
abstract type AbstractBasis end

include("PTM.jl")
include("HSH.jl")
include("RBF.jl")
include("BLN.jl")
include("YCC.jl")

struct Metadata
    width::Int32
    height::Int32
    format::String
    type::String
    colorspace::String
    nplanes::Int8
    materials::Vector{Dict{Symbol, Vector{Float64}}}
    quality::Int8
    sigma::Union{Nothing,Float64}
    lights::Union{Nothing,Vector{Float64}}
    basis::Union{Nothing,Vector{Int8}}
end

# Core types
struct Relightable{Basis<:AbstractBasis}
    basis::Basis
    metadata::Metadata
end

function Relightable()::Relightable{T} where T <: AbstractBasis
end

# JSON3 StructTypes
StructTypes.StructType(::Type{Relightable}) = StructTypes.Struct()
