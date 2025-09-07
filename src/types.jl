# Common fields across all bases
macro fields()
    esc(
        quote
            width::Int32
            height::Int32
            format::String
            type::String
            colorspace::String
            nplanes::Int8
            materials::Vector{Dict}
        end
    )
end

# Bases
abstract type Basis end

struct PTM <: Basis
    @fields
    quality::Int8
end
struct HSH <: Basis
    @fields
end
struct RBF <: Basis
    @fields
    sigma::Float64
    lights::Vector{Float64}
    basis::Vector{Int8}
end
struct BLN <: Basis
    @fields
    resolution::Int8
    basis::Int8
end
struct YCC{B<:Basis} <: Basis end

# Core type
struct Relightable{B<:Basis}
    base::Array{Float64,3}
    planes::Array{Float64,3}
    spec::B
end
