# bases/RBF.jl

## Basis type and constructor.
struct RBF <: AbstractBasis
    data::Array{Float64, 3}
    basis::Array{Float64, 3}
    lights::Matrix{Float16}
    σ::Float64
end

function RBF(
        A::Array{T, 3},
        basis::Vector{UInt8},
        lights::Vector{Float16},
        material::Material;
        sigma::Float64
    )::RBF where {T <: Real}

    dequantise!(
        A,
        material.scale,
        material.bias
    )

    # Shape of basis is 3×N×k.
    n_lights::Int = length(lights) / 3
    n_planes::Int = length(material.range)

    basis::Array{Float64, 3} = reshape(Float64.(basis), 3, n_lights, n_planes+1)
    lights::Matrix{Float16} = reshape(lights, (3, n_lights))

    basis[:, :, 1] ./= 255.0
    dequantise!(@view(basis[:, :, 2:end]), material.range)

    return RBF(
        A,
        basis,
        lights,
        sigma
    )
end

## Implements array-like behaviour.
Base.length(A::RBF) = length(A.data)
Base.size(A::RBF) = size(A.data)
Base.getindex(A::RBF, I...) = getindex(A.data, I...)
### TODO: Add Base.show method.

## Custom interface

function loaddir(::Type{RBF}, dir::String; scale::Real = 1)::RBF
    planes = glob("plane_*.jpg", dir)
    spec = joinpath(dir, "info.json") |> i -> Metadata(i)
    height::Int, width::Int = map([spec.height, spec.width]) do x
        x *= scale
        ceil(x)
    end
    buffer = Array{Float64, 3}(undef, (spec.nplanes, height, width))
    readplanes!(buffer, planes, scale) # Read planes into buffer.

    return RBF(buffer, spec.basis, spec.lights, spec.materials...; sigma = spec.sigma)
end

## Render methods

function ϕ(l::Vector{<:Real}, lᵢ::AbstractVector{<:Real}, σ::Float64)::Float64
    dist = (l - lᵢ) ⋅ (l - lᵢ) # Squared norm of distance vector.
    return exp(
        -(dist / σ^2)
    )
end

"""
    weight(l::Vector{Float64}, lights::Matrix{Float16}, σ::Float64, β::AbstractVector{Float64})::Float64  

Compute the light-dependent weight of an RBF plane.
"""
function weight(l::Vector{Float64}, lights::Matrix{Float16}, σ::Float64, β::AbstractVector{Float64})::Float64
    num = 0.0
    denom = 0.0
    @views for (lᵢ, βᵢ) in zip(eachslice(lights; dims = 2), β)
        ϕᵢ = ϕ(l, lᵢ, σ)
        num += ϕᵢ * βᵢ
        denom += ϕᵢ
    end

    if iszero(denom)
       return 0.0
    end

    return num / denom
end

function light(A::RBF, l::Vector{<:Real})::Matrix{RGB{Float64}}
    # Initialise image matrix.
    _, height, width = size(A)
    T = Array{Float64, 3}(undef, (3, height, width))

    normalize!(l)

    for c in axes(A.basis, 1) # Iterate over each colour channel `c`.
        # Compute light-dependent weights, separating the mean.
        B = @view A.basis[c, :, :]
        w₀, w... = [weight(l, A.lights, A.σ, Bₖ) for Bₖ in eachslice(B; dims = 2)]
        # Loop over pixel coefficients
        for x in axes(T, 2), y in axes(T, 3)
            a = view(A.data, :, x, y)
            T[c, x, y] += w₀
            T[c, x, y] += (a ⋅ w)
        end
    end
    return reinterpret(reshape, RGB{Float64}, T)
end
